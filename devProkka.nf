// module prokka
// 1. đặt tên PROKKA
process PROKKA {
    publishDir "${params.outdir}/prokka", mode: 'copy'

    input:
    // Đầu vào chỉ cần Tên mẫu và file Contigs (được tạo ra từ SPAdes)
    tuple val(meta), path(contigs)

    output:
    // Chọn 1 vài file
    tuple val(meta), path("${meta.id}/*.gff"), emit: gff
    tuple val(meta), path("${meta.id}/*.gbk"), emit: gbk
    tuple val(meta), path("${meta.id}/*.tsv"), emit: tsv

    script:
        // 1. Lấy tên file gốc nhưng gọt bỏ cái đuôi ".gz" đi (nếu có)
        // Ví dụ: "test.contigs.fa.gz" sẽ thành "test.contigs.fa"
        def input = contigs.toString() - ~/\.gz$/
        
        // 2. Kiểm tra xem file có đuôi "gz" không?
        // Nếu có: Tạo lệnh gunzip. Nếu không: Để trống (không làm gì cả).
        def decompress = contigs.getExtension() == "gz" ? "gunzip -c ${contigs} > ${input}" : ""
        
        // 3. Nếu lúc đầu có giải nén tạo file tạm, thì chạy xong phải xóa nó đi
        def cleanup = contigs.getExtension() == "gz" ? "rm ${input}" : ""

        // 4.
        """
        # 1. Chạy lệnh giải nén (Nó sẽ tự động kích hoạt hoặc nằm im tùy vào biến decompress)
        ${decompress}

        # 2. Chạy Prokka với tên file đã được tự động nhận diện
        prokka \\
            --cpus ${task.cpus} \\
            --outdir ${meta.id} \\
            --prefix ${meta.id} \\
            --genus "${meta.genus}" \\
            --species "${meta.species}" \\
            --strain "${meta.strain}" \\
            ${input}

        # 3. Dọn rác: Xóa file giải nén tạm thời để tiết kiệm ổ cứng
        ${cleanup}
        """
}