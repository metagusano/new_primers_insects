#!/usr/bin/env Rscript

#This script sends COI sequences to BOLD and retrieves the best hit together with the similarity between query and hit.


args = commandArgs(T)
if (length(args)!=2) {
  stop("Please enter a .fasta input file with the query sequences and table output file (.txt, .csv or .tab")
} else if (length(args)==2) {
  input_fasta <- args[1]
  output_table <- args[2]
}



# Read in sequences using seqinr
library(seqinr)
OTUS <- read.fasta(input_fasta)

# Loop over sequences and get best match from BOLD
library(XML)
library(curl)
taxa_seq <- NULL
taxa_BOLD <- NULL
similarities <- NULL
for (i in 1:length(OTUS)) {
        cat("Matching sequence ", i, "\n")
	seq <-getSequence(OTUS[i], as.string=T)[[1]][[1]]
	sendurl <- paste("http://boldsystems.org/index.php/Ids_xml?db=COX1_SPECIES_PUBLIC&sequence=", seq, sep="")
	http_request <- curl(url=sendurl)
	matches <- readLines(http_request)
	if ( matches != "<?xml version=\"1.0\"?><matches></matches>")
	{
		bestmatch <- xmlToList(matches)[1]
        	taxa_seq[i] <- names(OTUS[i])
		taxa_BOLD[i] <- bestmatch$match$taxonomicidentification
		similarities[i] <- bestmatch$match$similarity
		if ( i %% 100 == 0 )
        	{
		    results <-data.frame(taxon_seq=taxa_seq,taxon_BOLD=taxa_BOLD, similarity=similarities)
        	    write.table(results,"results_bold_XX.txt")
		}
	} else {
		taxa_seq[i] <- names(OTUS[i])
		taxa_BOLD[i] <- NA
	}
}

results <-data.frame(taxon_seq=taxa_seq,taxon_BOLD=taxa_BOLD, similarity=similarities)

write.table(results,output_table)


