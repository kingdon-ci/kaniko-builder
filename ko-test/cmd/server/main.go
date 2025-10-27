package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

// version will be set via ldflags during build
var version = "github-test-v1.0"

// AppInfo represents the application information
type AppInfo struct {
	Name        string    `json:"name"`
	Version     string    `json:"version"`
	BuildTime   time.Time `json:"build_time"`
	GoVersion   string    `json:"go_version"`
	Platform    string    `json:"platform"`
	BackendUsed string    `json:"backend_used"`
}

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Uptime    string    `json:"uptime"`
}

var startTime = time.Now()

func main() {
	// Get port from environment, default to 8080
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Determine which backend was used for build
	backendUsed := "unknown"
	if os.Getenv("KO_BUILT") != "" {
		backendUsed = "ko"
	} else if os.Getenv("KANIKO_BUILT") != "" {
		backendUsed = "kaniko"
	}

	// Create app info
	appInfo := AppInfo{
		Name:        "ko-demo-server",
		Version:     version,
		BuildTime:   time.Now(), // In real app, this would be build time
		GoVersion:   runtime.Version(),
		Platform:    fmt.Sprintf("%s/%s", runtime.GOOS, runtime.GOARCH),
		BackendUsed: backendUsed,
	}

	// Routes
	http.HandleFunc("/", homeHandler(appInfo))
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/info", infoHandler(appInfo))
	http.HandleFunc("/metrics", metricsHandler)

	log.Printf("🚀 Ko Demo Server starting on port %s", port)
	log.Printf("📊 Version: %s, Platform: %s, Backend: %s", 
		appInfo.Version, appInfo.Platform, appInfo.BackendUsed)

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("❌ Server failed to start:", err)
	}
}

func homeHandler(app AppInfo) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		
		html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>Ko Demo Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; color: #2c3e50; margin-bottom: 30px; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0; }
        .info-card { background: #ecf0f1; padding: 15px; border-radius: 5px; }
        .info-label { font-weight: bold; color: #34495e; }
        .success { color: #27ae60; }
        .endpoints { background: #3498db; color: white; padding: 20px; border-radius: 5px; margin-top: 20px; }
        .endpoint { margin: 5px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Ko Demo Server</h1>
            <p class="success">✅ Successfully running optimized Go application!</p>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Application:</div>
                %s v%s
            </div>
            <div class="info-card">
                <div class="info-label">Platform:</div>
                %s
            </div>
            <div class="info-card">
                <div class="info-label">Go Version:</div>
                %s
            </div>
            <div class="info-card">
                <div class="info-label">Build Backend:</div>
                %s
            </div>
        </div>

        <div class="endpoints">
            <h3>📡 Available Endpoints:</h3>
            <div class="endpoint">🏠 <strong>/</strong> - This page</div>
            <div class="endpoint">❤️ <strong>/health</strong> - Health check</div>
            <div class="endpoint">📊 <strong>/info</strong> - JSON application info</div>
            <div class="endpoint">📈 <strong>/metrics</strong> - Simple metrics</div>
        </div>

        <div style="margin-top: 30px; text-align: center; color: #7f8c8d;">
            <p><strong>hephy-builder Ko Backend Demo</strong></p>
            <p>Demonstrating optimized Go builds with distroless images</p>
        </div>
    </div>
</body>
</html>`, 
			app.Name, app.Version, app.Platform, app.GoVersion, app.BackendUsed)
		
		fmt.Fprint(w, html)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	uptime := time.Since(startTime).Round(time.Second)
	
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Uptime:    uptime.String(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func infoHandler(app AppInfo) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(app)
	}
}

func metricsHandler(w http.ResponseWriter, r *http.Request) {
	uptime := time.Since(startTime).Seconds()
	
	metrics := map[string]interface{}{
		"uptime_seconds":    uptime,
		"memory_alloc_mb":   bToMb(memUsage().Alloc),
		"memory_total_mb":   bToMb(memUsage().TotalAlloc),
		"memory_sys_mb":     bToMb(memUsage().Sys),
		"num_goroutines":    runtime.NumGoroutine(),
		"num_gc":           memUsage().NumGC,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(metrics)
}

func memUsage() runtime.MemStats {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m
}

func bToMb(b uint64) uint64 {
	return b / 1024 / 1024
}