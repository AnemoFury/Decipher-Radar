# Decipher Radar: Enterprise Architecture (100x Upgrade)

This document outlines the shift from standard CRUD operations to a high-performance, enterprise-grade fraud detection architecture inspired by Stripe and Swift.

## 1. High-Performance Core (Rust + gRPC)
Instead of a standard REST API, the core detection engine is built in **Rust** to ensure memory safety and zero-cost abstractions.
- **Protocol Buffers & gRPC**: Communication between services uses gRPC, reducing serialization overhead and ensuring low-latency data transfer (<5ms inter-service).
- **Non-blocking I/O**: The engine is fully asynchronous, handling thousands of concurrent signals per second.

## 2. Real-Time Data Streaming (Kafka & Redis)
- **Ingestion**: Transaction events are pushed into **Apache Kafka** topics as they occur.
- **Pre-Processing**: Kafka Streams handles real-time data cleaning and windowed aggregations.
- **L1 Cache**: **Redis** is used for millisecond-speed lookup of device fingerprints and IP reputation data.

## 3. Advanced Fraud Logic
- **Device Fingerprinting**: Capturing hardware UUIDs, canvas signatures, and font lists to generate unique `Device-ID`s. Detects if one device is rotating accounts.
- **3D Secure (3DS) Challengers**: A multi-stage pipeline where mid-risk transactions are not blocked but pushed into a "Challenge" state (FIDO/SMS).
- **Global Network Insights**: Comparing local behavior against anonymous "Global Signatures" (Swift Standard) to spot cross-platform anomalies.

## 4. Infrastructure & Scalability (Kubernetes)
- **K8s Deployments**: Services are containerized and deployed on Kubernetes for high availability.
- **Auto-Scaling (HPA)**: The system automatically scales from 3 to 50+ nodes during peak traffic (e.g., Black Friday) based on CPU/Memory load.
- **Zero-Downtime**: Rolling updates ensure logic can be deployed to production without dropping a single packet.

## 5. Performance Targets
- **Inference Latency**: < 50ms
- **End-to-End Latency**: < 150ms
- **Scalability**: Capable of 50k+ TPS (Transactions Per Second)
