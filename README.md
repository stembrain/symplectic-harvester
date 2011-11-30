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

      mvn clean install

look in examples-scripts/full-harvest-examples/example-symplectic

     cd examples-scripts/full-harvest-examples/example-symplectic

Configure the connection to you Vivo instance
    
    vi vivo.model.xml 

This is a direct connection the Vivo database. The harvester will read from there and write to there with additions. The Database should exist and have been populated by starting the Vivo application, however the Vivo application (Tomcat + Vivo war) doesn't need to be running to perform a harvest.

Configure the connection to you Elements Instance
    
    vi symplecticfetch.config.xml

see the documentation in that file for information.

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
    rm loadstate
    rm loadstate-fail
    sh run-fetch-only.sh
    # repeat the above until there is no more data to fetch
    sh run-ingest-only.sh


## Issues

If you find issues, please report them using https://github.com/ieb/symplectic-harvester/issues








