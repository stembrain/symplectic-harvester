package uk.co.tfd.symplectic.harvester;

public class AtomEntryLoadException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 6128085550465348423L;

	public AtomEntryLoadException(String message, Exception e) {
		super(message,e);
	}

}
