package main

import (
	"encoding/json"
	"fmt"
	"github.com/bacherfl/simple-go-service/metrics"
	"golang.org/x/time/rate"
	"strconv"
	"time"

	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	ResponseTimeSeconds = "0"
	Version             = "dev"
)

type ServiceInfo struct {
	Version string `json:"version"`
}

var rateLimiter *rate.Limiter

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	resp := ServiceInfo{Version: Version}

	responseTimeInt, _ := strconv.Atoi(ResponseTimeSeconds)

	<-time.After(time.Duration(responseTimeInt) * time.Second)

	if rateLimiter != nil {
		err := rateLimiter.Wait(r.Context())
		if err != nil {
			log.Println("Error while waiting for rate limiter: " + err.Error())
		}
	}

	payload, _ := json.Marshal(resp)

	if _, err := w.Write(payload); err != nil {
		log.Println("Could not send response: " + err.Error())
	}
}

func main() {
	router := mux.NewRouter()

	// gather and emit Prometheus metrics
	router.Use(metrics.MetricsHandler)
	router.Path("/metrics").Handler(promhttp.Handler())

	// render home page
	router.Path("/").HandlerFunc(serveHTTP)

	port, found := os.LookupEnv("SERVICE_PORT")
	if !found || port == "" {
		port = "9000"
	}
	if maxRequestsPerSecondStr := os.Getenv("MAX_REQUESTS_PER_SECOND"); maxRequestsPerSecondStr != "" {
		maxRequestsPerSecond, err := strconv.ParseInt(maxRequestsPerSecondStr, 10, 32)
		if err != nil {
			log.Println("Could not apply rate limit value of " + maxRequestsPerSecondStr + ": " + err.Error())
		}
		rateLimiter = rate.NewLimiter(rate.Limit(maxRequestsPerSecond), 20)
	}

	log.Printf("going to serve on port %s", port)
	if err := http.ListenAndServe(fmt.Sprintf(":%s", port), router); err != nil {
		log.Fatal(err)
	}
	log.Printf("exiting gracefully")
}
