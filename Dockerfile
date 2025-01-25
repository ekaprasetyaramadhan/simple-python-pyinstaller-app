# Menggunakan image Python versi 2
FROM python:2-alpine

# Menginstal dependensi sistem yang diperlukan
RUN apk add --no-cache gcc musl-dev libffi-dev

# Menginstal Flask
RUN pip install flask

# Menyalin aplikasi ke dalam container
COPY . /app

# Menetapkan direktori kerja
WORKDIR /app

# Menjalankan aplikasi Flask
CMD ["python", "app.py"]
