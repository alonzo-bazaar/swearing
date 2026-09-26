#!/usr/bin/env clj
(ns fuckery
  (:use clojure.repl) ;; uncomment for development
  (:require [clojure.string :as str]
            [clojure.data.json :as json]
            [org.httpkit.client :as client]))

;; I don't have the safest token management lol
(def home (System/getenv "HOME"))
(def gh-token (str/trim (slurp (str home "/.methlab/github-tokens/alonzo"))))

;; Get the body as a byte stream
(let [r @(client/get "https://api.github.com/search/code?q=pangoccioli"
                   {:headers {"Authorization" (str "Bearer " gh-token)
                              "X-Github-Api-Version" "22-11-28"
                              "Accept" "applicatoin/vnd.github+json"}})]
  (cond (not (= 200 (:status r))) (do (println "error! " (:status r)) (println r))
        :else (println (json/read-str (:body r)))))
