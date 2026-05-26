# Bacterial Genome Assembly & Annotation Pipeline

Một workflow tự động hóa viết bằng **Nextflow (DSL2)**, chuyên dụng cho việc lắp ráp de novo và chú thích hệ gen vi khuẩn từ dữ liệu giải trình tự thế hệ mới (short-read Illumina PE).

---

## Sơ đồ luồng công việc

```
Raw Reads (FASTQ PE)
        │
        ▼
  ┌──────────┐
  │  FASTP   │  ── Lọc chất lượng, cắt adapter
  └──────────┘
        │  clean_reads
        ▼
  ┌──────────┐
  │  SPAdes  │  ── De novo assembly
  └──────────┘
        │  contigs (.fa.gz)
        ▼
  ┌──────────┐
  │  PROKKA  │  ── Chú thích gen
  └──────────┘
        │
        ▼
  Kết quả (.gff / .gbk / .tsv)
```

| Bước | Công cụ | Chức năng | Đầu ra |
|------|---------|-----------|--------|
| 1 | **Fastp** | Quality control | `*_clean_R1/R2.fastq.gz`, báo cáo HTML/JSON |
| 2 | **SPAdes** | De novo assembly | `*.contigs.fa.gz`, `*.scaffolds.fa.gz` |
| 3 | **Prokka** | Gene annotation | `*.gff`, `*.gbk`, `*.tsv` |

---

## Yêu cầu hệ thống

| Phần mềm | Phiên bản |
|----------|-----------|
| Linux/Ubuntu | 20.04.6 |
| Java | 17.0.18 |
| Nextflow | 26.04.1  |
| Docker **hoặc** Singularity **hoặc** Conda |

---

## Hướng dẫn khởi chạy nhanh

### Bước 1 — Tải pipeline về máy

```bash
git clone https://github.com/sondoanletrung-arch/test.git
cd test
```

### Bước 2 — Chuẩn bị samplesheet

Tạo file `samplesheet.csv` (tab-separated) trong thư mục gốc của project theo mẫu sau:

```
sample	fastq_1	fastq_2	genus	species	strain
test	assets/real10k/DRR121928_1_10k.fastq.gz	assets/real10k/DRR121928_2_10k.fastq.gz	Escherichia	coli	K-12
```

| Cột | Mô tả |
|-----|-------|
| `sample` | Tên định danh mẫu (không chứa khoảng trắng) |
| `fastq_1` | Đường dẫn đến file read forward (R1) |
| `fastq_2` | Đường dẫn đến file read reverse (R2) |
| `genus` | Chi vi khuẩn (dùng cho Prokka) |
| `species` | Loài vi khuẩn (dùng cho Prokka) |
| `strain` | Chủng vi khuẩn (dùng cho Prokka) |
# Lưu ý: Cột genus,species, strain có thể bỏ trống hoặc "UNKNOWN"

### Bước 3 — Chạy pipeline

Chọn profile phù hợp với môi trường của bạn:

```bash
# Dùng Docker
nextflow run testmain.nf -profile docker

# Dùng Singularity
nextflow run testmain.nf -profile singularity

# Dùng Conda
nextflow run testmain.nf -profile conda
```

---

## Cấu trúc thư mục đầu ra

Sau khi pipeline chạy xong, kết quả được lưu trong thư mục `results/`:

```
results/
├── fastp/
│   ├── <sample>_clean_R1.fastq.gz    # Reads đã lọc (forward)
│   ├── <sample>_clean_R2.fastq.gz    # Reads đã lọc (reverse)
│   ├── <sample>_fastp.html           # Báo cáo QC (dạng HTML)
│   └── <sample>_fastp.json           # Báo cáo QC (dạng JSON)
├── spades/
│   ├── <sample>.contigs.fa.gz        # Contigs lắp ráp
│   └── <sample>.scaffolds.fa.gz      # Scaffolds lắp ráp
└── prokka/
    └── <sample>/
        ├── <sample>.gff              # Chú thích dạng GFF3
        ├── <sample>.gbk              # Chú thích dạng GenBank
        └── <sample>.tsv             # Bảng tóm tắt các gen
```

---

## Cấu hình tài nguyên

Tài nguyên mặc định cho từng bước được định nghĩa trong `nextflow.config`:

| Process | CPUs | RAM |
|---------|------|-----|
| FASTP | 2 | — |
| SPAdes | 2 | 4 GB |
| PROKKA | 2 | — |

Để thay đổi, chỉnh sửa trực tiếp trong file `nextflow.config` hoặc truyền tham số khi chạy:

```bash
nextflow run testmain.nf -profile docker --outdir my_results
```

---

## Thông tin Container & Conda

| Tool | Conda package | Docker/Singularity image |
|------|---------------|--------------------------|
| Fastp | `bioconda::fastp` | `community.wave.seqera.io/library/fastp:1.1.0` |
| SPAdes | `bioconda::spades` | `community.wave.seqera.io/library/spades:4.1.0` |
| Prokka | `bioconda::prokka` | `community.wave.seqera.io/library/prokka_openjdk` |

---

## Cấu trúc project

```
.
├── testmain.nf          # Workflow chính
├── devFastp.nf          # Module: Quality control
├── devSpades.nf         # Module: De novo assembly
├── devProkka.nf         # Module: Gene annotation
├── nextflow.config      # Cấu hình tài nguyên & profiles
├── samplesheet.csv      # File đầu vào mẫu
└── assets/
    └── real10k/         # Dữ liệu test (10k reads)
```