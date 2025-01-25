# Menggunakan Python versi 3.8-alpine sebagai base image
FROM python:3.8-alpine

# Menambahkan label metadata (opsional)
LABEL maintainer="Eka Prasetya Ramadhan" \
      description="Aplikasi Python dengan Flask dan executable menggunakan PyInstaller"

# Install dependensi sistem yang diperlukan untuk PyInstaller dan Flask
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    bash \
    binutils \
    build-base \
    python3-dev

# Install PyInstaller dan Flask
RUN pip install --no-cache-dir pyinstaller flask

# Menyalin seluruh kode aplikasi ke direktori /app di dalam container
COPY . /app

# Menetapkan direktori kerja
WORKDIR /app

# Membuat executable dengan PyInstaller
RUN pyinstaller --onefile sources/add2vals.py

# Expose port 5000 untuk aplikasi Flask
EXPOSE 5000

# Menjalankan executable yang dihasilkan oleh PyInstaller
ENTRYPOINT ["./dist/add2vals", "10", "20"]
