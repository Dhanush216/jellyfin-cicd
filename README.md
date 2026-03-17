# Jellyfin on Kubernetes 🚀

## 📌 Overview
Self-hosted Jellyfin media server deployed on Kubernetes using CI/CD automation.

## 🏗 Pre-requisites
- Kubernetes (KinD)
- Helm
- Terraform
- Cloudflare Tunnel

## ⚙️ Features
- Secure public access
- Automated deployment
- Persistent storage

## 📸 Architecture
<img width="1024" height="1536" alt="Image Mar 17, 2026, 11_58_16 AM" src="https://github.com/user-attachments/assets/a08154ca-ffc0-4c09-8565-32512a69de5d" />

## # 🚀 Deployment Steps

## 1️⃣ Create KinD Cluster

* Create a Kubernetes cluster using **KinD** with a custom configuration file.
* Configure:

  * `extraPortMappings` → expose NodePort services to host
  * `hostPath mounts` → map local media directories into cluster

```bash
kind create cluster --config kind-config.yaml
```

---

## 2️⃣ Install Prerequisites

Ensure the following tools are installed:

* kubectl → Kubernetes CLI
* Helm → Package manager for Kubernetes
* Terraform → Infrastructure as Code tool

```bash
kubectl version --client
helm version
terraform version
```

---

## 3️⃣ Configure Supporting Services

### 🔹 MinIO (Terraform Backend)

* Deploy MinIO locally
* Configure it as **remote backend** for Terraform state storage

### 🔹 Cloudflared

* Install and configure **Cloudflare Tunnel**
* Create systemd services for both:

```bash
sudo systemctl enable minio
sudo systemctl enable cloudflared
sudo systemctl start minio
sudo systemctl start cloudflared
```

---

## 4️⃣ Configure Helm Values

Update Helm values files:

### jellyfin-values.yaml

* Set:

  * Persistent storage (`hostPath` / PVC)
  * Media mount path
  * Service type → `NodePort`
  * NodePort → match KinD config

### prometheus-values.yaml

* Enable monitoring stack
* Configure scraping and service exposure

---

## 5️⃣ Configure Terraform

Inside `terraform/` directory:

### Files:

* `provider.tf` → Kubernetes + Helm providers
* `helm.tf` → Jellyfin Helm release
* `monitoring.tf` → Prometheus stack
* `backend.tf` → MinIO S3 backend

### Initialize Terraform:

```bash
terraform init
```

---

## 6️⃣ Setup GitHub Actions Runner (Self-Hosted)

* Download and configure GitHub self-hosted runner
* Start runner:

```bash
./run.sh
```

* Ensure runner is active and connected to repository

---

## 7️⃣ Configure CI/CD Pipeline

Inside `.github/workflows/`:

### Pipeline Steps:

* Checkout repository
* Setup Terraform
* Run:

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

* Pipeline runs on push to main branch

---

## 8️⃣ Configure Cloudflare Tunnel

* Create a tunnel and config file:

```yaml
tunnel: jellyfin-tunnel
credentials-file: /root/.cloudflared/credentials.json

ingress:
  - hostname: your-domain.com
    service: http://<laptop-ip>:<nodeport>
  - service: http_status:404
```

* Route DNS:

```bash
cloudflared tunnel route dns jellyfin-tunnel your-domain.com
```

---

## 9️⃣ Access Application 🌐

* Open browser:

```bash
https://your-domain.com
```

* Jellyfin UI should be accessible securely via Cloudflare

---

## ✅ Result

* Fully automated deployment using CI/CD
* Secure public access without exposing ports
* Persistent media storage
* Monitoring enabled with Prometheus

---

## ⚠️ Challenges & Learnings

### 🔌 Kubernetes Networking (KinD + NodePort)

* Faced issues with **NodePort not being accessible externally**
* Debugged **extraPortMappings configuration in KinD**
* Learned how container networking differs from real clusters

---

## 🎥 Media Conversion (H.265 → H.264)

Some devices (e.g., Android TV) may not support **H.265 (HEVC)** playback properly in Jellyfin.
To ensure compatibility, media can be converted to **H.264 (AVC)** using FFmpeg.

### 🔧 Conversion Command

```bash
ffmpeg -i <movie_H265.mp4> -c:v libx264 -preset slow -crf 20 -c:a copy <movie_H264.mp4>
```

---

### 📌 Explanation

* `-i <movie_H265.mp4>` → Input file (H.265 encoded video)
* `-c:v libx264` → Convert video codec to H.264
* `-preset slow` → Better compression (smaller size, slower processing)
* `-crf 20` → Quality level (lower = better quality, typical range: 18–23)
* `-c:a copy` → Keep original audio without re-encoding

---

### ⚖️ Notes

* Use `crf 18` → Higher quality (larger file size)
* Use `crf 23` → Smaller size (slightly lower quality)
* Conversion helps avoid buffering and playback failures on unsupported devices

---

### 🚀 Alternative (Batch Conversion)

```bash
for file in *.mp4; do
  ffmpeg -i "$file" -c:v libx264 -preset slow -crf 20 -c:a copy "converted_$file"
done
```

---

## ✅ Result

* Improved playback compatibility across devices
* Reduced dependency on real-time transcoding
* Smoother streaming experience in Jellyfin

---

### 🌐 Cloudflare Tunnel Issues

* Initial misconfiguration caused domain to not route properly
* Fixed:

  * Incorrect service mapping (`localhost:NodePort`)
  * DNS routing with Cloudflare
* Learned secure exposure without opening ports publicly

---

### ⚙️ Terraform State Management

* Needed a remote backend → implemented **MinIO (S3-compatible)**
* Understood:

  * State locking concepts
  * Remote backend configuration
* Improved reliability of CI/CD deployments

---

### 🔄 CI/CD Pipeline Debugging

* Issues with self-hosted GitHub runner setup
* Fixed:

  * Runner connectivity
  * Terraform execution errors inside pipeline
* Learned end-to-end automation workflow

---

## 📸 Screenshots

### 🎬 Jellyfin UI

<img width="1364" height="624" alt="Screenshot from 2026-03-17 12-09-18" src="https://github.com/user-attachments/assets/15a74368-015d-4bec-af7f-e3ec660e0d08" />


### ⚙️ CI/CD Pipeline (GitHub Actions)

<img width="1364" height="624" alt="Screenshot from 2026-03-17 12-10-46" src="https://github.com/user-attachments/assets/f5f524ab-20c3-4b03-998a-993c6151251a" />

### 📸 Minio Dashboard

<img width="1364" height="624" alt="Screenshot from 2026-03-17 12-19-01" src="https://github.com/user-attachments/assets/fc6ccda7-591f-482a-99b5-3944f82a9461" />


### 📊 Monitoring Dashboard (Prometheus / Grafana)

<img width="1364" height="624" alt="Screenshot from 2026-03-17 12-14-48" src="https://github.com/user-attachments/assets/990f5f91-4985-43c7-901d-2e0105f3f51a" />
<img width="1364" height="624" alt="Screenshot from 2026-03-17 12-16-12" src="https://github.com/user-attachments/assets/7e5c7d29-3350-4056-8a65-4bc5158fd9ab" />

## 🚀 What This Project Demonstrates

* Real-world **DevOps workflow**
* Kubernetes hands-on experience
* CI/CD automation using GitHub Actions
* Secure application exposure using Cloudflare Tunnel
* Troubleshooting and debugging skills
