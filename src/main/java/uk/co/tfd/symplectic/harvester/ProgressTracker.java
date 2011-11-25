package uk.co.tfd.symplectic.harvester;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.repo.RecordHandler;

public class ProgressTracker {

	private static final Logger LOGGER = LoggerFactory
			.getLogger(ProgressTracker.class);
	private File chkFile;
	private Map<String, AtomEntryLoader> toLoad = new LinkedHashMap<String, AtomEntryLoader>();
	private Set<String> loaded = new HashSet<String>();
	private File loadstateFile;
	private File loadstateFileSafe;
	private RecordHandler recordHandler;

	public ProgressTracker(String fileName, RecordHandler recordHandler) {
		chkFile = new File(fileName + ".chk");
		loadstateFile = new File(fileName);
		loadstateFileSafe = new File(fileName + ".safe");
		this.recordHandler = recordHandler;
	}

	public void checkpoint() throws IOException {

		DataOutputStream out = new DataOutputStream(new FileOutputStream(
				chkFile));
		out.writeLong(System.currentTimeMillis());
		out.writeInt(toLoad.size());
		out.writeInt(loaded.size());
		for (Entry<String, AtomEntryLoader> e : toLoad.entrySet()) {
			out.writeUTF(e.getKey());
			out.writeUTF(e.getValue().getType());
		}
		for (String s : loaded) {
			out.writeUTF(s);
		}
		out.close();
		loadstateFileSafe.delete();
		loadstateFile.renameTo(loadstateFileSafe);
		chkFile.renameTo(loadstateFile);
		loadstateFileSafe.delete();
		LOGGER.info("Checkpoint done");
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
		for (int i = 0; i < ntoload; i++) {
			String url = in.readUTF();
			String type = in.readUTF();
			if ("relationship".equals(type)) {
				toLoad.put(url, new APIRelationship(recordHandler, this));
			} else {
				toLoad.put(url, new APIObject(recordHandler, type, this));
			}
		}
		for (int i = 0; i < nloaded; i++) {
			loaded.add(in.readUTF());
		}
		LOGGER.info("Checkpoint Loaded {} {}", toLoad.size(), loaded.size());

	}

	public void toload(String url, AtomEntryLoader loader) {
		if (!loaded.contains(url) && !toLoad.containsKey(url)) {
			toLoad.put(url, loader);
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
		return toLoad.entrySet().iterator().next();
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
