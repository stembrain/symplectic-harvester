/*
 *  Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
 *  Please see the LICENSE file for more details
 */
package uk.co.tfd.symplectic.harvester;


/**
 * Generic interface to load Atom Entries
 * @author ieb
 *
 */
public interface AtomEntryLoader {

	/**
	 * @param item the Atom Entry to be parsed
	 * @throws AtomEntryLoadException
	 */
	void loadEntry(String url) throws AtomEntryLoadException;

	
	String getType();


}
