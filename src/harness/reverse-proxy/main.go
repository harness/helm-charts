package main

import (
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
)

func main() {
	target := "BACKEND_SERVICE_URL"
	proxyURL, _ := url.Parse(target)

	proxy := httputil.NewSingleHostReverseProxy(proxyURL)
	proxy.Director = func(req *http.Request) {
		req.URL.Scheme = proxyURL.Scheme
		req.URL.Host = proxyURL.Host

		//rewrite logic here.
		req.URL.Path = strings.Replace(req.URL.Path, "<old-path>", "<new-path>", 1)
	}

	log.Println("Starting reverse proxy on :8080...")
	http.ListenAndServe(":8080", proxy)
}
