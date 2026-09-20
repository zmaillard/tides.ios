(ns stations
  (:require [clojure.java.io :as io]
            [clojure.data.csv :as csv]
            [babashka.http-client :as http]
            [cheshire.core :as json]))


(defn get-station
  [id]
  (-> (http/get (str "https://api.tidesandcurrents.noaa.gov/mdapi/prod/webapi/stations/" id ".json"))
      :body
      (json/parse-string true)))

(defn build-station
  [[region id name]]
  (let [station-data (get-station id)]
    (assoc {} 
           :region region
           :id id
           :name name
           :greatlakes  (get-in station-data [:stations 0 :greatlakes])
           :tideType (get-in station-data [:stations 0 :tideType])
           :lat (get-in station-data [:stations 0 :lat])
           :lng (get-in station-data [:stations 0 :lng])
           :timezone (get-in station-data [:stations 0 :timezone])
           :tidal (get-in station-data [:stations 0 :tidal])
           :observedst (get-in station-data [:stations 0 :observedst]) 
           :timezonecorr (get-in station-data [:stations 0 :timezonecorr]) 
           :state (get-in station-data [:stations 0 :state]))))
(defn -main
  [& [path output next-version]]
  (with-open [rdr (io/reader path)]
    (let [rows (csv/read-csv rdr)
          xformed (reduce #(conj %1 (build-station %2)) [] rows)]
      (spit output (json/generate-string {:version next-version :stations xformed}
                                         {:pretty true})))))
