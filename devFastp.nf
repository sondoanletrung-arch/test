//module fastp

// 1. Đặt tên FATSP
process FASTP {
    publishDir "${params.outdir}/fastp", mode: 'copy' // Xuất kết quả ra thư mục results/fastp, copy để dễ dàng truy cập sau này

    // 2. Định nghĩa input và output
    input:
    tuple val(meta), path(read1), path(read2) // Nhận vào một tuple gồm: Thông tin mẫu (meta), Read 1 và Read 2

    output:
    tuple val(meta), path("${meta.id}_clean_R1.fastq.gz"), path("${meta.id}_clean_R2.fastq.gz"), emit: clean_reads // Xuất ra các reads đã được làm sạch + metadata
    tuple val(meta), path("${meta.id}_fastp.json")           , emit: json // Xuất ra file JSON
    tuple val(meta), path("${meta.id}_fastp.html")           , emit: html // Xuất ra file HTML

    // 3. Viết script để chạy fastp
    // Đầu vào là 2 file read1, read2 được định nghĩa ở input
    // Đầu ra là 2 file đã được làm sạch, cùng với báo cáo JSON và HTML
    // Các kết quả từ script sẽ được tạo ra ở work, cần output để lấy ra các kết quả cần thiết
    script:
    """
    fastp \\
        --in1 ${read1} --in2 ${read2} \\
        --out1 ${meta.id}_clean_R1.fastq.gz --out2 ${meta.id}_clean_R2.fastq.gz \\
        --html ${meta.id}_fastp.html \\
        --json ${meta.id}_fastp.json \\
        --thread ${task.cpus}
    """
}