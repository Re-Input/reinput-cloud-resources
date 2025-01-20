#!/bin/bash

# 에러 발생 시 스크립트 중단
set -e

echo "=== 시스템 패키지 업데이트 ==="
sudo apt-get update

echo "=== Docker 설치 준비 ==="
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "=== Docker GPG 키 및 레포지토리 추가 ==="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== Docker 설치 ==="
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "=== Docker 서비스 설정 ==="
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

echo "=== AWS CLI 설치 ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt-get install -y unzip
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "=== 디렉토리 생성 및 권한 설정 ==="
mkdir -p ~/.ssh
chmod 700 ~/.ssh
sudo mkdir -p /var/log/docker
sudo chown -R $USER:$USER /var/log/docker

echo "=== 모니터링 도구 설치 ==="
sudo apt-get install -y htop ncdu

echo "=== 방화벽 설정 ==="
sudo apt-get install -y ufw
sudo ufw allow ssh
sudo ufw allow 8761  # Discovery Server 포트
echo "y" | sudo ufw enable

echo "=== 타임존 설정 ==="
sudo timedatectl set-timezone Asia/Seoul

echo "=== 설치 확인 ==="
echo "Docker 버전:"
docker --version

echo "AWS CLI 버전:"
aws --version

echo "=== AWS CLI 설정 안내 ==="
echo "다음 명령어로 AWS CLI를 설정하세요:"
echo "aws configure"
echo "AWS Access Key ID 입력"
echo "AWS Secret Access Key 입력"
echo "Default region name: us-east-1"
echo "Default output format: json"

echo "=== ECR 로그인 테스트 안내 ==="
echo "다음 명령어로 ECR 로그인을 테스트하세요:"
echo "aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/e7w4k6e4"

echo "=== 설치 완료 ==="
echo "시스템을 재시작하거나 다음 명령어를 실행하여 Docker 그룹 설정을 적용하세요:"
echo "newgrp docker" 