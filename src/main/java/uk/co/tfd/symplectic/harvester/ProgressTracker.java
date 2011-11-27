package uk.co.tfd.symplectic.harvester;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.fetch.nih.NIHFetch;
import org.vivoweb.harvester.util.repo.RecordHandler;

public class ProgressTracker {

	private static final Logger LOGGER = LoggerFactory
			.getLogger(ProgressTracker.class);
	private File chkFile;
	private Map<String, AtomEntryLoader> toLoad = new HashMap<String, AtomEntryLoader>();
	private Set<String> loaded = new HashSet<String>();
	private File loadstateFile;
	private File loadstateFileSafe;
	private RecordHandler recordHandler;
	private List<String> toLoadList = new LinkedList<String>();

	public ProgressTracker(String fileName, RecordHandler recordHandler) {
		chkFile = new File(fileName + ".chk");
		loadstateFile = new File(fileName);
		loadstateFileSafe = new File(fileName + ".safe");
		this.recordHandler = recordHandler;
		try {
			load();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		Runtime.getRuntime().addShutdownHook(new Thread() {
			@Override
			public void run() {
				try {
					checkpoint();
					LOGGER.info("Check point complete ToLoad {} Loaded {} ",toLoadList.size(), loaded.size());
				} catch (IOException e) {
					LOGGER.error("Failed to checkpoint ",e);
				}
			}
		});
	}

	public void checkpoint() throws IOException {

		DataOutputStream out = new DataOutputStream(new FileOutputStream(
				chkFile));
		out.writeLong(System.currentTimeMillis());
		out.writeInt(toLoadList.size());
		out.writeInt(loaded.size());
		for (String url : toLoadList) {
			AtomEntryLoader loader = toLoad.get(url);
			out.writeUTF(url);
			out.writeUTF(loader.getType());
		}
		for (String s : loaded) {
			out.writeUTF(s);
		}
		out.close();
		loadstateFileSafe.delete();
		loadstateFile.renameTo(loadstateFileSafe);
		chkFile.renameTo(loadstateFile);
		loadstateFileSafe.delete();
	}

	public void load() throws IOException {
		File toloadFile = null;
		if (loadstateFile.exists()) {
			toloadFile = loadstateFile;
		} else if (loadstateFileSafe.exists()) {
			toloadFile = loadstateFileSafe;
		} else {
			return;
		}
		DataInputStream in = new DataInputStream(
				new FileInputStream(toloadFile));
		long lastSave = in.readLong();
		int ntoload = in.readInt();
		int nloaded = in.readInt();
		toLoad.clear();
		loaded.clear();
		toLoadList.clear();
		LOGGER.info("Loading ToDo List {}  Loaded List {} ",ntoload, nloaded);
		for (int i = 0; i < ntoload; i++) {
			String url = in.readUTF();
			String type = in.readUTF();
			if ("relationship".equals(type)) {
				toLoad.put(url, new APIRelationship(recordHandler, this));
			} else if ("relationships".equals(type)) {
					toLoad.put(url, new APIRelationships(recordHandler, this));
			} else if ( type.endsWith("s")) {
				toLoad.put(url, new APIObjects(recordHandler, type, this));
			} else {
				toLoad.put(url, new APIObject(recordHandler, type, this));
			}
			toLoadList.add(url);
		}
		for (int i = 0; i < nloaded; i++) {
			loaded.add(in.readUTF());
		}
		LOGGER.info("Checkpoint Loaded {} {}", toLoad.size(), loaded.size());

	}

	public void toload(String url, AtomEntryLoader loader) {
		if (!loaded.contains(url) && !toLoad.containsKey(url)) {
			LOGGER.info("added {} ",url);
			toLoad.put(url, loader);
			toLoadList.add(url);
			try {
				checkpoint();
			} catch (IOException e) {
				LOGGER.info("Checkpoint Failed {} ", e.getMessage(), e);
			}
		}
	}

	public void loaded(String url) {
		toLoad.remove(url);
		loaded.add(url);
		toLoadList.remove(url);
		LOGGER.info("done {} ",url);
		try {
			checkpoint();
		} catch (IOException e) {
			LOGGER.info("Checkpoint Failed {} ", e.getMessage(), e);
		}
	}

	public boolean hasPending() {
		return toLoad.size() > 0;
	}

	public int pending() {
		return toLoad.size();
	}

	public Entry<String, AtomEntryLoader> next() {
		final String url = toLoadList.get(0);
		final AtomEntryLoader loader = toLoad.get(url);
		return new Entry<String, AtomEntryLoader>() {
			
			@Override
			public AtomEntryLoader setValue(AtomEntryLoader value) {
				return null;
			}
			
			@Override
			public AtomEntryLoader getValue() {
				return loader;
			}
			
			@Override
			public String getKey() {
				return url;
			}
		};
	}

	public void dumpLoaded() {
		for (String s : loaded) {
			LOGGER.info("Loaded {} ", s);
		}
		for (String s : toLoad.keySet()) {
			LOGGER.info("Pending {} ", s);
		}
	}

}
