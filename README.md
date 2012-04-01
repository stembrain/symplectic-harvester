# Vivo Harvester for Symplectic Elements

This file is written in Markdown, best viewed at http://github-preview.herokuapp.com/ or https://github.com/ieb/symplectic-harvester

## Introduction

  This code base enables selected information within a Symplectic Elements installation (http://www.symplectic.org) to be ingested into a Vivo (http://www.vivoweb.org) instance.
  The code uses Vivo Harvester, 1.2 targetting a Vivo Instance 1.3.

## Installation

Build and deploy Vivo 1.3

Build and deploy Vivo Harvester remembering to deploy dependencies. 


      git clone git@github.com:ieb/vivo-harvester.git
      cd vivo-harvester
      git checkout symplectic
      mvn clean dependency:copy-dependencies install


Build this package

      git clone git@github.com:ieb/symplectic-harvester.git
      cd symplectic-harvester
      mvn clean install

look in examples-scripts/full-harvest-examples/example-symplectic

     cd examples-scripts/full-harvest-examples/example-symplectic
     
Configure the locations of the harvester installation and the other OS level things.

     vi symplectic-tools.config    

Configure the connection to you Vivo instance
    
    vi vivo.model.xml 

This is a direct connection the Vivo database. The harvester will read from there and write to there with additions. The Database should exist and have been populated by starting the Vivo application, however the Vivo application (Tomcat + Vivo war) doesn't need to be running to perform a harvest.

Test that the vivo model is correctly configured.

     sh jenna-connect.sh vivo.model.xml  " select ?s ?v where { ?s <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#updatedOntology> ?v } "
     
This should produce 1 result. 

Configure the connection to you Elements Instance
    
    vi symplecticfetch.config.xml

Configure the db connection for the harvester. 

    vi fetcher-db.config.xml
    
The harvester maintains a list of all the URLs it has retrieved in a database. This enables it to main a list of urls it has retrieved and when they were retrieved. If you need to restart the harvester and you want to load a clean set you will need to empty the table first. In earlier versions a file was stored on disk to perform this task, however this approach is more manageable.
    
see the documentation in that file for information.


Modify symplectic-to-vivo.datamap.xsl to set the baseUrl to whatever is configured for you Vivo instance. If my instance was called vivo.symplectic.co.uk I would need to change

     <xsl:variable name="baseURI">http://vivo.tfd.co.uk/individual/</xsl:variable>
     
to

     <xsl:variable name="baseURI">http://vivo.symplectic.co.uk/individual/</xsl:variable>
     
     

## Scripts

* Once configured there are 3 scripts you may run.
    * __run-fetch-only.sh__: this fetches all data staring from the list of users from a Symplectic Elements API. It performs a maximum of 10K URL requests and then exits. It stores its data under data/raw-records and checkpoints the state of the fetch in 2 binary files, loadstate and loadstate-failed. At the end of each run, all the data and the state of the fetch are copied to datasafe/. The fetch operation may be restarted multiple times and will complete when there are no pending URLs to be loaded. The file loadstate contains the pending URLs and the fetched URLs. loadstate-failed contains the urls that failed. The contents of these files are listed at the end of each run.
   * __run-ingest-only.sh__: this takes the data in data/raw-records and ingests it into Vivo. At each step, only new data is processed and the final state of the previous harvest operation is stored in previous-harvest/
* run-symplectic.sh: combines run-fetch-only.sh and run-ingest-only.sh, once a system has been hargested for the first time, this is probably the best script to use.
   * __remote-last-symplectic-harvest.sh__: removes the last harvest from vivo and updates the previous harvest model. Unless addition and subtraction files have been saved at each harvest operation, this can only be performed once. ie it will only remove the last harvest, not the one before that.
   * __jenna-connect.sh__: allows abritary SPARQL queries to be run agains any of the models eg jenna-connect.sh vivi.model.xml will run select ?s ?p ?v where ( ?s ?p ?v ) aginst the vivo data model. (expect lots and lots of output if you do that)



## Running

I recommend that you do 


    sh run-fetch-only.sh   
    sh run-ingest-only.sh


the first time and then

    sh run-symplectic.sh

after that.

## Known Limitations

The fetch operation does not currently support re-fetching new resources, however it will fetch items that appear in a list, if the updateLists parameter is set to true. To completely update from scratch, do the following.


    rm -rf data
    rm -rf previous-harvest
    
    # clean the database containing the fetch state. In mysql this table is called symplectic_fetch
    
    sh run-fetch-only.sh
    # repeat the above until there is no more data to fetch
    sh run-ingest-only.sh


## Issues

If you find issues, please report them using https://github.com/ieb/symplectic-harvester/issues








