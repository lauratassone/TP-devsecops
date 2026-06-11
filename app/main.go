package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

func writeJSON(w http.ResponseWriter, status int, payload map[string]string) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("X-Frame-Options", "DENY")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("write response: %v", err)
	}
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			writeJSON(w, http.StatusNotFound, map[string]string{"error": "not_found"})
			return
		}

		writeJSON(w, http.StatusOK, map[string]string{
			"service": "tp-devsecops-harbor-demo",
			"status":  "ok",
		})
	})

	mux.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "healthy"})
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Demo app listening on %s", port)
	// TLS is terminated by the Kubernetes ingress or the external DAST target.
	// nosemgrep: go.lang.security.audit.net.use-tls.use-tls
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatal(err)
	}
}
