/*
 *  Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
 *  Please see the LICENSE file for more details
 */
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
