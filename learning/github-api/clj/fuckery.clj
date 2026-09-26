#!/usr/bin/env clj
(ns fuckery
  (:use clojure.repl) ;; uncomment for development, comment for deployment
  (:require [clojure.string :as str]
            [clojure.java.io :as io]
            [clojure.data.json :as json]
            [org.httpkit.client :as client]))

;;; configuration variables/parameters
(def gh-api-version "2026-03-10")
(def gh-token (str/trim (slurp (str (System/getenv "HOME")
                                    "/.methlab/github-tokens/alonzo"))))
(def word-list-file  "../wordlist.txt")
(def output-csv-file "./counts.csv")

;;; utils
;; I don't like clojure's syntax for kwargs and this was the fastest way to
;; get around it
;; TODO: this hack does not work for multimethods
;; TODO: this hack does not work if you have kwargs + other variadics
(defmacro defn-kw [name args & body]
  (let [[last second-last & rv-positional] (reverse args)]
    (if (and (= '& second-last) (map? last))
      `(defn ~name [~@(reverse rv-positional)
                    & ~{:keys (mapv (fn [x] x) (keys last))
                        :or   last}]
         ~@body)
      `(defn ~name ~args ~@body))))

;; file line reading-writing functions
;; https://clojure-doc.org/articles/cookbooks/files_and_directories/
(defn read-lines
  ([file-name line-fun]
   (with-open [rdr (io/reader file-name)]
     (mapv line-fun (line-seq rdr))))
  ([file-name]
   (read-lines file-name (fn [x] x))))

(defn write-lines [file-name lines]
  (with-open [wrtr (io/writer file-name)]
    (doseq [line lines]
      (.write wrtr (str line "\n")))))

;; business logic
(defn try-find-occurences [word]
  @(client/get
    (str "https://api.github.com/search/code?q=" word "&per_page=1")
    {:headers {"Accept" "applicatoin/vnd.github+json"
               "X-Github-Api-Version" gh-api-version
               "Authorization" (str "Bearer " gh-token)}}))

;; TODO: flush partially read data on request failure
(defn-kw get-word-list-counts [words & {sleep-after-success 6000
                                        sleep-after-timeout 6000
                                        log-current-word    false
                                        max-tries           5}]
  (loop [counts []
         words words
         try-number 1]
    (if (empty? words)
      {:status 'ok :data counts}
      (let* [head (first words)
             tail (rest  words)
             r (try-find-occurences head)]
        (if log-current-word
          (println (str "fetched occurence count for [" head "]...")))
        (cond 
          ;; :error is a field added by http-kit if some shit gets fucked in
          ;; the request itself, (if (:error r)) then we're like
          ;; fuck it, hcf, eat shit and die, morte di cacca addosso
          (:error r)
          {:status 'fuck
           :data r
           :loop-state [counts words try-number]}

          ;; status != 200 assumed to mean we have been timed out
          ;; timeout handled by waiting then retrying
          ;; if max number of tries has been already reached then
          ;; we shit ourselves and die
          (not (= (:status r) 200))
          (if (>= try-number max-tries)
            {:status 'too-many-retries
             :data r
             :loop-state [counts words try-number]
             }
            (do (Thread/sleep sleep-after-timeout)
                (recur counts words (+ 1 try-number))))

          ;; we got a 200, yippie! :D
          :else
          (let [count (get (json/read-str (:body r)) "total_count")]
            (if-not count
              {:status 'fuck
               :data r
               :loop-state [counts words]
               }
              (let [next-counts (conj counts count)
                    next-words  tail]
                (do (Thread/sleep sleep-after-success)
                    (recur next-counts next-words 1))))))))))

(defn words-freqs-csv-lines [words]
  (let [try-counts (get-word-list-counts words :sleep-after-success 1000 :log-current-word true)]
    (if (= 'ok (:status try-counts))
      (let [counts (:data try-counts)]
        (-> []
            (into ["word,count"])
            (into (mapv #(str %1 "," %2) words counts))))
      ["word,count"
       "fuck,you"])))

(def word-list (read-lines  str/trim))
(write-lines 
