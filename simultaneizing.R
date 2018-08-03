#!/usr/bin/env Rscript
#Generates new ecoPCR files with the species amplified by two primer pairs and the species amplified by one primer pair but not the other (for calculation of Simultaneously Combined ETR, Marquina et al. 2018)

args = commandArgs(T)
if (length(args)!=4) {
  stop("Please enter a .ecopcr input file with from the first primer pair, a .txt input file with the list of species amplified by the second primer pair, and .ecopcr output files for 1) uniquely contributed ETR and 2) redundantly contributed ETR")
} else if (length(args)==4) {
  input_pcr_one <- args[1]
  input_pcr_two <- args[2]
  output_pcr_unique <- args[3]
  output_pcr_redundant <- args[4]
}

pcr_one <- readLines(input_pcr_one)
ecopcr_seqs <- pcr_one[14:length(pcr_one)]
ecopcr_data <- pcr_one[1:13]
amplified <- strsplit(ecopcr_seqs, "[|]")
amplified <- data.frame(amplified)
species_amplified <- data.frame(t(amplified))

pcr_two = readLines(input_pcr_two)

seq_out = unlist(sapply(pcr_two, function(n) {
  which(n == species_amplified$X6)
}))
length(seq_out)

unique_ecopcr <- ecopcr_seqs[-c(seq_out)]
length(unique_ecopcr)
writeLines(c(ecopcr_data, unique_ecopcr), output_pcr_unique)

redundant_ecopcr <- ecopcr_seqs[(seq_out)]
redundant_ecopcr <- unique(redundant_ecopcr)
length(redundant_ecopcr)
writeLines(c(ecopcr_data, redundant_ecopcr), output_pcr_redundant)
