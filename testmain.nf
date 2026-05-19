#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// 1. Nhập các module từ đường dẫn tương ứng
include { FASTP }  from './devFastp.nf'
include { SPADES } from './devSpades.nf'
include { PROKKA } from './devProkka.nf'

// 2. Chạy workflow
workflow {
    
    // Lấy dữ liệu từ file CSV và tạo channel
    reads_ch = Channel.fromPath("samplesheet.csv") // Tìm file CSV chứa thông tin mẫu
        .splitCsv(header: true) // Tách file csv thành các dòng và sử dụng dòng đầu làm header
        .map { row -> // lấy từng dòng và xử lý
            def meta = [
                id:      row.sample,
                genus:   row.genus,
                species: row.species,
                strain:  row.strain
            ]
            
            def read1 = file(row.fastq_1) // Lấy đường dẫn đến file fastq_1 từ dòng csv
            def read2 = file(row.fastq_2) // Lấy đường dẫn đến file fastq_2 từ dòng csv
            
            return tuple(meta, read1, read2) // Trả về một tuple chứa metadata và đường dẫn đến file fastq
        }

    // Nối ống
    FASTP(reads_ch) // Trong module fastp, đầu ra được dùng để vào module spades là emit: clean_reads
    SPADES(FASTP.out.clean_reads) // Trong module spades, đầu ra được dùng để vào module prokka là emit: contigs
    PROKKA(SPADES.out.contigs) // Hoặc SPADES.out.scaffolds
    
}