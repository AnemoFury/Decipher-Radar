# Decipher Radar: High-Performance Fraud Detection System

Decipher Radar is a scalable, AI-powered fraud prevention platform designed for modern enterprises. It leverages a microservices architecture to process transactions in real-time, detect anomalies using machine learning, and visualize global threats on an interactive dashboard.

## 🚀 Features

- **Real-Time Fraud Detection**: Analyzes transaction velocity, geolocation mismatches, and spending patterns instantly.
- **Interactive Global Dashboard**: visualise threats and transaction flow on a 3D interactive globe.
- **Microservices Architecture**: Decoupled services for payment processing, fraud analysis, and frontend delivery.
- **Scalable Infrastructure**: Containerized with Docker for seamless deployment and scaling.
- **Secure Integration**: Uses Stripe for payment processing and Supabase for data persistence.

## 🛠️ Technology Stack

### Frontend
- **HTML5 / CSS3**: High-performance, semantic markup.
- **Tailwind CSS**: Utility-first styling for rapid UI development.
- **Three.js**: Advanced 3D visualizations for the global threat map.
- **JavaScript (ES6+)**: Interactive client-side logic.

### Backend & Services
- **FastAPI (Python)**: High-performance async API for the Machine Learning Engine.
- **Spring Boot (Java)**: Robust payment processing microservice.
- **MySQL**: Relational database for transaction and user data.
- **Supabase**: Start-up friendly database for rapid prototyping and real-time features.

### Infrastructure
- **Docker & Docker Compose**: Complete containerization of all services.
- **Nginx**: Production-grade web server for the frontend.

## 🏁 Getting Started

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running.

### Installation & Running

1.  **Clone the repository** (if you haven't already):
    ```bash
    git clone https://github.com/yourusername/deciper-radar.git
    cd deciper-radar
    ```

2.  **Environment Configuration**:
    The project includes a `.env` file with placeholder credentials. For local development, the defaults usually work, but you can update them if you have your own API keys.
    ```bash
    # (Optional) Edit .env file
    # STRIPE_API_KEY=sk_test_...
    # SUPABASE_URL=https://...
    ```

3.  **Build and Run with Docker Compose**:
    This command will build the images for the frontend, backend, and payment services, and start the entire stack.
    ```bash
    docker-compose up --build
    ```
    *Note: The first build may take a few minutes as it downloads dependencies.*

### 📍 Accessing the Application

Once the services are up and running, you can access them at:

| Service | URL | Description |
| :--- | :--- | :--- |
| **Frontend Dashboard** | [http://localhost](http://localhost) | Main user interface and Globe visualization. |
| **ML Engine API** | [http://localhost:8000](http://localhost:8000) | FastAPI backend documentation (Swagger UI at `/docs`). |
| **Payment Service** | [http://localhost:8081](http://localhost:8081) | Java Spring Boot payment processing. |
| **Database** | `localhost:3306` | MySQL Database access. |

## 🧪 Testing Fraud Detection

To test the fraud detection engine:
1.  Navigate to the **Console** (`/console.html`) on the frontend.
2.  Use the **"Simulate Signal"** button to generate random transactions.
3.  Observe the real-time log for `APPROVED`, `REVIEW`, or `BLOCKED` decisions based on the risk score.
4.  High-risk transactions will trigger visual alerts on the dashboard.

## 📂 Project Structure

```
├── backend/            # Python FastAPI ML Engine
├── frontend/           # HTML/JS/Three.js Frontend
├── payment-service/    # Java Spring Boot Payment Service
├── docker-compose.yml  # Orchestration configuration
├── .env                # Environment variables
└── README.md           # Project documentation
```


This project is licensed under the MIT License - see the LICENSE file for details.


## Key Skills Highlighted
- **Java / Spring Boot**: Robust backend architecture and microservices.
- **MySQL**: Relational database management and query optimization.
- **OOPS Concepts**: Encapsulation, inheritance, and polymorphism for modular code.
- **REST APIs**: Secure and scalable communication between services.
- **Docker & Kubernetes**: Containerized deployment for cloud-native scalability.

## Tech Stack
- **Frontend**: React, Tailwind CSS, Three.js (for global threat visualization).
- **Backend Architecture**: Spring Boot Microservices.
- **Database**: MySQL with indexing for high-frequency transactions.
- **Infrastructure**: Dockerized services orchestrated by Kubernetes.
- **Intelligence**: Real-time AI fraud detection engine.


This project covers OOPS, databases, Java, and basic system design—essential for roles at **Walmart, Amazon, or Snowflake**.

## Goal
Build the software that handles users, products, and orders with a focus on high-performance fraud detection.


## 📄 License
