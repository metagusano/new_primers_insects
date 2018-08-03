#!/usr/bin/env Rscript

#This script removes from an ecoPCR output those species already amplified in a previous ecoPCR (for Residually Combined ETR calculation, Marquina et al. 2018).

args = commandArgs(T)
if (length(args)!=3) {
  stop("Please enter a .ecopcr input file with from residual primer pair, a .txt input file with the list of species amplified by the original primer pair, and .ecopcr output file")
} else if (length(args)==3) {
  input_pcr <- args[1]
  input_table <- args[2]
  output_pcr <- args[3]
}

original_pcr <- readLines(input_pcr)
ecopcr_seqs <- original_pcr[14:length(original_pcr)]
ecopcr_data <- original_pcr[1:13]
amplified <- strsplit(ecopcr_seqs, "[|]")
amplified <- data.frame(amplified)
species_amplified <- data.frame(t(amplified))

unwanted_names = readLines(input_table)

seq_out = unlist(sapply(unwanted_names, function(n) {
  which(n == species_amplified$X6)
}))
#seq_out

residual_ecopcr <- ecopcr_seqs[-c(seq_out)]
residual_ecopcr <- na.omit(residual_ecopcr)
length(residual_ecopcr)
writeLines(c(ecopcr_data, residual_ecopcr), output_pcr)
