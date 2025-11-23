# Dùng image Python chính thức
FROM python:3.11-slim

# Đặt thư mục làm việc trong container
WORKDIR /app

# Copy file requirements và cài đặt dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ code vào container
COPY . .

# Expose port cho FastAPI
EXPOSE 8000

# Chạy ứng dụng bằng Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
