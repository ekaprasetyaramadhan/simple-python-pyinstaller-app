# Menggunakan image Python versi 2-alpine sebagai base image
FROM python:2-alpine

# Install dependensi sistem yang diperlukan untuk PyInstaller dan Flask
RUN apk add --no-cache gcc musl-dev libffi-dev

# Install PyInstaller untuk membuat executable
RUN pip install pyinstaller flask

# Menyalin seluruh kode aplikasi ke dalam direktori /app di dalam container
COPY . /app

# Menetapkan direktori kerja
WORKDIR /app

# Membuat executable dengan PyInstaller
RUN pyinstaller --onefile sources/add2vals.py

# Expose port 80 untuk aplikasi Flask
EXPOSE 80

# CMD untuk menjalankan executable yang dihasilkan oleh PyInstaller
CMD ["./dist/add2vals"]
