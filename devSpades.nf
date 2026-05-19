// module Spades

// 1. Gọi SPADES
process SPADES {
    publishDir "${params.outdir}/spades", mode: 'copy'

    // 2. Định nghĩa input và output
    input:
    tuple val(meta), path(read1), path(read2)

    output:
    // 3 cái cần thiết là contigs, scaffolds
    tuple val(meta), path("${meta.id}.contigs.fa.gz")  , emit: contigs
    tuple val(meta), path("${meta.id}.scaffolds.fa.gz"), emit: scaffolds

    // 3. Script chạy Spades
    script:
    """
    # a. Chạy Spades cho dữ liệu Ilumina PE, sử dụng read1 và read2 làm input, xuất kết quả ra thư mục hiện tại (./), sử dụng số luồng và bộ nhớ được phân bổ cho task
    spades.py \\
        -1 ${read1} \\
        -2 ${read2} \\
        -o ./ \\
        --threads ${task.cpus} \\
        --memory ${task.memory.toGiga()}

    # b. Đổi tên và nén file kết quả
    # (SPAdes mặc định xuất ra tên chung chung là contigs.fasta, phải đổi tên thành '${meta.id}.contigs.fa'
    
    mv spades.log ${meta.id}.spades.log #đổi tên log file

    # Nếu có file contigs.fasta, đổi tên và nén nó. Tương tự với scaffolds.fasta. -f để nén mà không thêm header vào tên file, -n để không thêm phần mở rộng .gz vào tên file sau khi nén
    if [ -f contigs.fasta ]; then
        mv contigs.fasta ${meta.id}.contigs.fa
        gzip -n ${meta.id}.contigs.fa
    fi

    if [ -f scaffolds.fasta ]; then
        mv scaffolds.fasta ${meta.id}.scaffolds.fa
        gzip -n ${meta.id}.scaffolds.fa
    fi
    """
}