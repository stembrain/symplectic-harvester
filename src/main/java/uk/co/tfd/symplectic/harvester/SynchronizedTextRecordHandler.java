package uk.co.tfd.symplectic.harvester;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.vivoweb.harvester.util.repo.Record;
import org.vivoweb.harvester.util.repo.TextFileRecordHandler;

public class SynchronizedTextRecordHandler extends TextFileRecordHandler {

    private Object lock = new Object();

    public SynchronizedTextRecordHandler() {
    }

    public SynchronizedTextRecordHandler(String fileDir) throws IOException {
        super(fileDir);
    }

    @Override
    public void setParams(Map<String, String> params) throws IllegalArgumentException, IOException {
        synchronized (lock) {
            super.setParams(params);
        }
    }

    @Override
    public boolean addRecord(Record rec, Class<?> operator, boolean overwrite) throws IOException {
        synchronized (lock) {
        return super.addRecord(rec, operator, overwrite);
        }
    }

    @Override
    public void delRecord(String recID) throws IOException {
        synchronized (lock) {
        super.delRecord(recID);
        }
    }

    @Override
    public String getRecordData(String recID) throws IllegalArgumentException, IOException {
        synchronized (lock) {
        return super.getRecordData(recID);
        }
    }

    @Override
    public Iterator<Record> iterator() {
        synchronized (lock) {
            ArrayList<Record> r = new ArrayList<Record>();
            Iterator<Record> i = super.iterator();
            while(i.hasNext()) r.add(i.next());
            return r.iterator();
        }
    }

    @Override
    public void close() throws IOException {
        synchronized (lock) {
            super.close();
        }
    }

    @Override
    public Set<String> find(String idText) {
        synchronized (lock) {
            return super.find(idText);
        }
    }

    @Override
    public boolean addRecord(String recID, String recData, Class<?> creator, boolean overwrite) throws IOException {
        synchronized (lock) {
            return super.addRecord(recID, recData, creator, overwrite);
        }
    }

    @Override
    public boolean addRecord(Record rec, Class<?> creator) throws IOException {
        synchronized (lock) {
            return super.addRecord(rec, creator);
        }
    }

    @Override
    public boolean addRecord(String recID, String recData, Class<?> creator) throws IOException {
        synchronized (lock) {
            return super.addRecord(recID, recData, creator);
        }
    }

    @Override
    public Record getRecord(String recID) throws IllegalArgumentException, IOException {
        synchronized (lock) {
            return super.getRecord(recID);
        }
    }

    @Override
    public void setOverwriteDefault(boolean overwrite) {
        synchronized (lock) {
            super.setOverwriteDefault(overwrite);
        }
    }

    @Override
    public boolean isOverwriteDefault() {
        synchronized (lock) {
            return super.isOverwriteDefault();
        }
    }

    @Override
    public boolean needsProcessed(String id, Class<?> operator) {
        synchronized (lock) {
            return super.needsProcessed(id, operator);
        }
    }
    
}
