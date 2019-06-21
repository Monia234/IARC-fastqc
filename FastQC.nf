#!/usr/bin/env nextflow

// Copyright (C) 2017 IARC/WHO

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


params.help = null
params.config = null
params.fastqc = "fastqc"
params.multiqc = "multiqc"
params.input_folder = "FASTQ/"
params.output_folder = "."
params.ext      = "fastq.gz"

log.info ""
log.info "----------------------------------------------------------------"
log.info "    Unaligned reads quality control with FastQC and MultiQC     "
log.info "----------------------------------------------------------------"
log.info "Copyright (C) IARC/WHO"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "--------------------------------------------------------"
if (params.help) {
    log.info "--------------------------------------------------------"
    log.info "                     USAGE                              "
    log.info "--------------------------------------------------------"
    log.info ""
    log.info "----------nextflow pipeline for QC on fastq files-------"
    log.info ""
    log.info "nextflow run FastQC.nf --input_folder path/to/fastq/ --fastqc path/to/fastqc/ --multiqc path/to/multiqc/  --output_folder /path/to/output"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--input_folder         FOLDER               Folder containing fastq files"
    log.info "--output_folder        PATH                 Output directory for html and zip files (default=fastqc_ouptut)"
    log.info ""
    log.info "Optional arguments:"
    log.info "--multiqc              PATH                 MultiQC installation dir (default=multiqc)"
    log.info "--fastqc               PATH                 FastQC installation dir (default=fastqc)"
    log.info "--config               FILE                 Use custom configuration file"
    log.info ""
    log.info "Flags:"
    log.info "--help                                      Display this message"
    log.info ""
    exit 0
}

assert (params.input_folder != null) : "please provide the --input_folder option"

fastqs = Channel.fromPath( params.input_folder+'/*.'+params.ext )
              .ifEmpty { error "Cannot find any file with extension ${params.ext} in: ${params.input_folder}" }

process fastqc {

  tag { fastqc_tag }

  publishDir "${params.output_folder}", mode: 'copy' 

  input:
  file f from fastqs

  output:
  file ("*fastqc.zip") into fastqc_results

  shell:
  fastqc_tag=f.baseName.replace("${params.ext}","")
  '''
  !{params.fastqc} -o . !{f}
  '''
}

process multiqc {

    publishDir "${params.output_folder}", mode: 'copy', pattern: '{multiqc_report.html}'

    input:
    file fastqc_results from fastqc_results.collect()

    output:
    file("multiqc_report.html") into final_output

    shell:
    '''
    !{params.multiqc} .
    '''
}
