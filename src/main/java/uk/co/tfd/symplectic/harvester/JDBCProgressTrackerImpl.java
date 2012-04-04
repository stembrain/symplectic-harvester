package uk.co.tfd.symplectic.harvester;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class JDBCProgressTrackerImpl implements ProgressTracker {

    private static final String MAX_URL_AGE = "max-url-age";
    private static final String DDL = "ddl";
    private static final String JDBC_PASSWORD = "jdbc-password";
    private static final String JDBC_USER = "jdbc-user";
    private static final String JDBC_CLASS = "jdbc-class";
    private static final String JDBC_URL = "jdbc-url";
    private static final String CONFIG_DB_FILE = "fetcher-db.config.xml";
    private static final String CHECK_DB_SQL = "check-db-sql";
    private static final String UPDATE_URL_STATE_SQL = "update-url-state-sql";
    private static final String INSERT_URL_STATE_SQL = "insert-url-state-sql";
    private static final String COUNT_STATUS_SQL = "count-status-sql";
    private static final String SELECT_ON_STATUS_SQL = "select-on-status-sql";
    private static final String SELECT_ON_STATUS_SQL_LIMIT1 = "select-on-status-limit1-sql";
    private static final String INSERT_URL_STATE_TOLOAD_SQL = "insert-url-state-toload-sql";
    private static final String UPDATE_URL_STATE_TOLOAD_SQL = "update-url-state-toload-sql";
    private static final String SELECT_URL_SQL = "select-url";
    private static final Charset UTF8 = Charset.forName("UTF8");
    private static final int OK = 200;
    private static final int FAILED = 500;
    private static final int PENDING = 0;
    private static final int LOADING = 1;
    private static final Logger LOGGER = LoggerFactory.getLogger(JDBCProgressTrackerImpl.class);
    private RecordHandler recordHandler;
    private int limitListPages;
    private Connection connection;
    private boolean updateLists;
    private Map<String, PreparedStatement> statements = new HashMap<String, PreparedStatement>();
    private Document sqlConfig;
    private Timestamp reloadBefore;
    private Node dialectNode;
    private Object dblock = new Object();
    private String[] objectTypes;

    public JDBCProgressTrackerImpl(RecordHandler recordHandler, int limitListPages, boolean updateLists, String[] objectTypes)
            throws SQLException, IOException {
        connect(getSql(JDBC_URL), getSql(JDBC_CLASS), getSql(JDBC_USER), getSql(JDBC_PASSWORD));
        create();
        this.recordHandler = recordHandler;
        this.limitListPages = limitListPages;
        this.updateLists = updateLists;
        this.objectTypes = objectTypes;
        reloadBefore = new Timestamp(System.currentTimeMillis() - (Long.parseLong(getConfigProperty(MAX_URL_AGE)) * 1000L));
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                try {
                    shutdown();
                } catch (Exception e) {
                    LOGGER.error("Failed to checkpoint ", e);
                }
            }
        });

    }

    protected void shutdown() throws IOException, SQLException {
        synchronized (dblock) {
            clearLoading();
            checkpoint();
            LOGGER.info("Check point complete ToLoad {} Loaded {} ", pending(), loaded());
            connection.close();
            connection = null;
        }

    }

    private String getConfigProperty(String key) throws IOException {
        loadConfig();
        return XmlAide.findAttribute(sqlConfig.getDocumentElement(), key);
    }

    private PreparedStatement getPreparedStatement(String key) throws SQLException, IOException {
        PreparedStatement p = statements.get(key);
        if (p == null) {
            p = connection.prepareStatement(getSql(key));
            statements.put(key, p);
        }
        return p;
    }

    private String getSql(String key) throws IOException {
        loadConfig();
        return XmlAide.getNodeValue(dialectNode, key);
    }

    private void loadConfig() throws IOException {
        if (sqlConfig == null) {
            try {
                sqlConfig = XmlAide.loadXmlDocument(new File(CONFIG_DB_FILE).toURI().toURL().toString());
            } catch (SAXException e) {
                LOGGER.error(e.getMessage(), e);
                throw new IOException(e);
            } catch (ParserConfigurationException e) {
                LOGGER.error(e.getMessage(), e);
                throw new IOException(e);
            }
            String dialectNodeName = XmlAide.findAttribute(sqlConfig.getDocumentElement(), "db-type");
            LOGGER.info("Selected Dialect {} ", dialectNodeName);
            dialectNode = XmlAide.findNode(sqlConfig.getDocumentElement(), dialectNodeName);
            LOGGER.info("Selected Dialect Node {} ", dialectNode);
        }
    }

    private void create() {
        Statement s = null;
        ResultSet rs = null;
        try {
            s = connection.createStatement();
            try {
                rs = s.executeQuery(getSql(CHECK_DB_SQL));
                if (rs.next()) {
                    return;
                }
            } catch (SQLException e) {

            }
            safeClose(rs);
            Node createdb = XmlAide.findNode(dialectNode, "createdb");
            NodeList nl = createdb.getChildNodes();
            for (int i = 0; i < nl.getLength(); i++) {
                Node n = nl.item(i);
                if (DDL.equals(n.getNodeName())) {
                    s.execute(n.getTextContent());
                }
            }
            connection.commit();
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        } finally {
            safeClose(rs);
            safeClose(s);

        }
    }

    private void safeClose(ResultSet rs) {
        try {
            rs.close();
        } catch (Exception e) {
        }
    }

    private void safeClose(Statement s) {
        try {
            s.close();
        } catch (Exception e) {
        }
    }

    private void connect(String url, String dbClass, String dbUser, String dbPassword) {
        try {
            Class.forName(dbClass);
            connection = DriverManager.getConnection(url, dbUser, dbPassword);
            connection.setAutoCommit(false);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
    }

    @Override
    public void loaded(String url) {
        if (connection == null) {
            return;
        }
        mark(url, OK);
    }

    private String hash(String url) {
        try {
            return Base64.encodeBase64URLSafeString(MessageDigest.getInstance("SHA1").digest(url.getBytes(UTF8)));
        } catch (NoSuchAlgorithmException e) {
            return url;
        }
    }

    @Override
    public void loadedFailed(String url) {
        if (connection == null) {
            return;
        }
        mark(url, FAILED);
    }

    @Override
    public boolean isLoaded(String url) {
        if (connection == null) {
            return false;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement checkLoaded = getPreparedStatement(SELECT_URL_SQL);
                    checkLoaded.clearParameters();
                    checkLoaded.setString(1, hash(url));
                    rs = checkLoaded.executeQuery();
                    if (rs.next()) {
                        // url, lastupdate, loadstate, loader_type, id
                        int loadState = rs.getInt(3);
                        Timestamp lastUpdate = rs.getTimestamp(2);
                        if (lastUpdate.before(reloadBefore) || loadState == PENDING) {
                            return false;
                        }
                        return true;
                    }
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
                return false;
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query isLoaded {}ms ", end);
            }
        }
    }

    private void clearLoading() {
        if (connection == null) {
            return;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement selectOnStatus = getPreparedStatement(SELECT_ON_STATUS_SQL);
                    selectOnStatus.clearParameters();
                    selectOnStatus.setInt(1, LOADING);
                    rs = selectOnStatus.executeQuery();
                    while (rs.next()) {
                        String url = rs.getString(1);
                        mark(url, PENDING);
                    }
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query clearLoading {}ms ", end);
            }
        }
    }

    @Override
    public void toload(String url, AtomEntryLoader loader) {
        if (connection == null) {
            return;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                if ((updateLists && (loader instanceof AtomEntryLoader)) || !isLoaded(url)) {
                    try {
                        try {
                            PreparedStatement updateUrlStateToLoad = getPreparedStatement(UPDATE_URL_STATE_TOLOAD_SQL);
                            updateUrlStateToLoad.clearParameters();
                            updateUrlStateToLoad.setString(1, url);
                            updateUrlStateToLoad.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                            updateUrlStateToLoad.setInt(3, PENDING);
                            updateUrlStateToLoad.setString(4, loader.getType());
                            updateUrlStateToLoad.setString(5, hash(url));
                            updateUrlStateToLoad.executeUpdate();
                        } catch (SQLException e) {
                            PreparedStatement insertUrlStateToLoad = getPreparedStatement(INSERT_URL_STATE_TOLOAD_SQL);
                            insertUrlStateToLoad.clearParameters();
                            insertUrlStateToLoad.setString(1, url);
                            insertUrlStateToLoad.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                            insertUrlStateToLoad.setInt(3, PENDING);
                            insertUrlStateToLoad.setString(4, loader.getType());
                            insertUrlStateToLoad.setString(5, hash(url));
                            insertUrlStateToLoad.executeUpdate();
                        }
                    } catch (IOException e) {
                        LOGGER.error(e.getMessage(), e);
                    } catch (SQLException e) {
                        LOGGER.error(e.getMessage(), e);
                    }
                }
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query toLoad {}ms ", end);
            }
        }

    }

    @Override
    public boolean hasPending() {
        if (connection == null) {
            return false;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement countStatus = getPreparedStatement(COUNT_STATUS_SQL);
                    countStatus.clearParameters();
                    countStatus.setInt(1, PENDING);
                    rs = countStatus.executeQuery();
                    int n = 0;
                    if (rs.next()) {
                        n = rs.getInt(1);
                    }
                    if (n > 0)
                        return true;
                    countStatus = getPreparedStatement(COUNT_STATUS_SQL);
                    countStatus.clearParameters();
                    countStatus.setInt(1, LOADING);
                    rs = countStatus.executeQuery();
                    if (rs.next()) {
                        n = n + rs.getInt(1);
                    }
                    return (n > 0);
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
                return false;
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query hasPending {}ms ", end);
            }
        }

    }

    @Override
    public int pending() {
        if (connection == null) {
            return 0;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement countStatus = getPreparedStatement(COUNT_STATUS_SQL);
                    countStatus.clearParameters();
                    countStatus.setInt(1, PENDING);
                    rs = countStatus.executeQuery();
                    int n = 0;
                    if (rs.next()) {
                        n = rs.getInt(1);
                    }
                    countStatus = getPreparedStatement(COUNT_STATUS_SQL);
                    countStatus.clearParameters();
                    countStatus.setInt(1, LOADING);
                    rs = countStatus.executeQuery();
                    if (rs.next()) {
                        n = n + rs.getInt(1);
                    }
                    return n;
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
                return 0;
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query pending {}ms ", end);
            }
        }

    }

    private int loaded() {
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement countStatus = getPreparedStatement(COUNT_STATUS_SQL);
                    countStatus.clearParameters();
                    countStatus.setInt(1, OK);
                    rs = countStatus.executeQuery();
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
                return 0;
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query loaded {}ms ", end);
            }
        }

    }

    @Override
    public Entry<String, AtomEntryLoader> next() {
        if (connection == null) {
            return null;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                ResultSet rs = null;
                try {
                    PreparedStatement selectOnStatus = getPreparedStatement(SELECT_ON_STATUS_SQL_LIMIT1);
                    selectOnStatus.clearParameters();
                    selectOnStatus.setInt(1, PENDING);
                    rs = selectOnStatus.executeQuery();
                    if (rs.next()) {
                        String url = rs.getString(1);
                        String type = rs.getString(4);
                        mark(url, LOADING);
                        if ("relationship".equals(type)) {
                            return new MapEntry(url, new APIRelationship(recordHandler, this, limitListPages, objectTypes));
                        } else if ("relationships".equals(type)) {
                            return new MapEntry(url, new APIRelationships(recordHandler, this, limitListPages, objectTypes));
                        } else if (type.endsWith("s")) {
                            return new MapEntry(url, new APIObjects(recordHandler, type, this, limitListPages, objectTypes));
                        } else {
                            return new MapEntry(url, new APIObject(recordHandler, type, this, limitListPages, objectTypes));
                        }
                    }
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                } finally {
                    try {
                        rs.close();
                    } catch (Exception ex) {
                    }
                }
                return null;
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query next {}ms ", end);
            }
        }

    }

    @Override
    public void dumpLoaded() {
        if (connection == null) {
            return;
        }
        synchronized (dblock) {
            ResultSet rs = null;
            try {
                PreparedStatement selectOnStatus = getPreparedStatement(SELECT_ON_STATUS_SQL);
                selectOnStatus.clearParameters();
                selectOnStatus.setInt(1, PENDING);
                rs = selectOnStatus.executeQuery();
                while (rs.next()) {
                    String url = rs.getString(1);
                    Timestamp lastUpdated = rs.getTimestamp(2);
                    String type = rs.getString(4);
                    LOGGER.info("To Load Url {} type {} ", new Object[] { url, type, lastUpdated });
                }
                rs.close();
                selectOnStatus.clearParameters();
                selectOnStatus.setInt(1, OK);
                rs = selectOnStatus.executeQuery();
                while (rs.next()) {
                    String url = rs.getString(1);
                    Timestamp lastUpdated = rs.getTimestamp(2);
                    String type = rs.getString(4);
                    LOGGER.info("Loaded Url {} type {} ", new Object[] { url, type, lastUpdated });
                }
                rs.close();
                selectOnStatus.clearParameters();
                selectOnStatus.setInt(1, FAILED);
                rs = selectOnStatus.executeQuery();
                while (rs.next()) {
                    String url = rs.getString(1);
                    Timestamp lastUpdated = rs.getTimestamp(2);
                    String type = rs.getString(4);
                    LOGGER.info("Failed Url {} type {} ", new Object[] { url, type, lastUpdated });
                }
                rs.close();
            } catch (IOException e) {
                LOGGER.error(e.getMessage(), e);
            } catch (SQLException e) {
                LOGGER.error(e.getMessage(), e);
            } finally {
                try {
                    rs.close();
                } catch (Exception ex) {
                }
            }
        }
    }

    @Override
    public void checkpoint() throws IOException {
        if (connection == null) {
            return;
        }
        synchronized (dblock) {
            try {
                connection.commit();
            } catch (SQLException e) {
                LOGGER.error(e.getMessage(), e);
            }
        }
    }

    private void mark(String url, int code) {
        if (connection == null) {
            return;
        }
        long start = System.currentTimeMillis();
        try {
            synchronized (dblock) {
                try {
                    try {
                        PreparedStatement insertUrlState = getPreparedStatement(INSERT_URL_STATE_SQL);
                        insertUrlState.clearParameters();
                        insertUrlState.setString(1, url);
                        insertUrlState.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                        insertUrlState.setInt(3, code);
                        insertUrlState.setString(4, hash(url));
                        insertUrlState.executeUpdate();
                    } catch (SQLException e) {
                        PreparedStatement updateUrlState = getPreparedStatement(UPDATE_URL_STATE_SQL);
                        updateUrlState.clearParameters();
                        updateUrlState.setString(1, url);
                        updateUrlState.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
                        updateUrlState.setInt(3, code);
                        updateUrlState.setString(4, hash(url));
                        updateUrlState.executeUpdate();
                    }
                } catch (IOException e) {
                    LOGGER.error(e.getMessage(), e);
                } catch (SQLException e) {
                    LOGGER.error(e.getMessage(), e);
                }
            }
        } finally {
            long end = System.currentTimeMillis() - start;
            if (end > 100) {
                LOGGER.info("Slow Query mark {}ms ", end);
            }
        }

    }

}
