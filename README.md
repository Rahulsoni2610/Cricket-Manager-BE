# Cricket Manager

This project is fully dockerized to support a seamless development experience for both the Ruby on Rails backend and the React frontend. Both applications communicate natively within a single Docker compose network.

## Project Structure

The project root contains two main directories and a docker-compose configuration:
- `cricket_manager/` - The Ruby on Rails API backend.
- `cricket-manager-frontend/` - The React (Vite) frontend.

## Prerequisites

- **Docker** and **Docker Compose** installed on your system.

## Setup Instructions

### 1. Environment Variables

In the root folder (`cricket-2026`), ensure you have a `.env` file that includes your Rails secrets:
```env
DEVISE_JWT_SECRET_KEY=your_jwt_secret_key_here
RAILS_MASTER_KEY=your_rails_master_key_here
```
*(Replace the values with the actual secrets provided by your team if starting from scratch).*

### 2. Build and Run the App

From the root configuration directory (`cricket-2026` - where the `docker-compose.yml` resides), run the following command to build the images and install dependencies:

```bash
docker-compose up --build
```
*Note: The first time you run this, it will take some time to download the images and install Ruby gems and Node.js modules.*

### 3. Access the Services

Once the containers are up and running, you can access the applications locally:

* **Frontend (React/Vite)**: [http://localhost:5173](http://localhost:5173)
* **Backend API (Rails)**: [http://localhost:3000](http://localhost:3000)
* **PostgreSQL Database**: Exposed on `localhost:5432`

## Useful Docker Commands

**Stop the servers:**
To stop the currently running containers gracefully, use `Ctrl+C` in the terminal where it's running, or run from another terminal:
```bash
docker-compose stop
```

**Run everything in the background:**
```bash
docker-compose up -d
```

**View logs from all containers:**
```bash
docker-compose logs -f
```

**Run Rails console:**
You can open an interactive Rails debug console within the running backend container:
```bash
docker exec -it cricket_backend ./bin/rails console
```

**Run Database Migrations (if needed manually):**
*Note: The current `docker-compose.yml` automatically runs rails db:prepare, but if you need to run specific commands manually:*
```bash
docker exec -it cricket_backend ./bin/rails db:migrate
```

**Install new dependencies:**
If you change `Gemfile` or `package.json`, you generally just need to rebuild the containers:
```bash
docker-compose up --build
```

**Interactive Debugging (binding.pry / debugger):**
The backend container is configured with `stdin_open` and `tty`, allowing you to attach to it and interact with debuggers.
When your code hits a `debugger` or `binding.pry`:
1. Open a new terminal.
2. Attach to the backend container:
   ```bash
   docker attach cricket_backend
   ```
3. You will be dropped into the interactive ruby console.
*Note: To detach without killing the server, press `Ctrl+P` followed by `Ctrl+Q`. Do not press `Ctrl+C`!*

**Testing on External Devices With Cloudflare Tunnel:**
We've included a `cloudflare_tunnel` service to expose the frontend to the internet easily (no account or auth token required!).
1. Start the services with `docker-compose up`.
2. Check the tunnel logs to find your public URL by running:
   ```bash
   docker-compose logs cloudflare_tunnel | grep trycloudflare
   ```
3. Look for a URL that looks like `https://something.trycloudflare.com` and open it on your device.
*Note: If you want to expose the backend instead, edit the `cloudflare_tunnel` service `command` in `docker-compose.yml` to point to `http://backend:3000`.*
