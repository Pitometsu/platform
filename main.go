package main

import (
	"os"
	"fmt"
	"net/http"
	"encoding/json"
	"database/sql"
	_ "github.com/lib/pq"
)

type Request struct {
	Api string `json:"api"`
	Data json.RawMessage `json:"data"`
}

type BalanceRequestData struct {
	GameSessionId string `json:"gameSessionId"`
	Currency string `json:"currency"`
}

type BalanceResponse struct {
	Api string `json:"api"`
	Data struct {
	    UserNick string `json:"userNick"`
		Amount int64 `json:"amount"`
		Denomination int `json:"denomination"`
		MaxWin int64 `json:"maxWin"`
		Currency string `json:"currency"`
		UserId string `json:"userId"`
		JpKey string `json:"jpKey"`
	} `json:"data"`
}

type FundsRequestData struct {
	UserNick string `json:"userNick"`
	Amount int64 `json:"amount"` // negative amount possible???
	Denomination int `json:"denomination"`
	MaxWin int64 `json:"maxWin"`
	Currency string `json:"currency"`
	UserId string `json:"userId"`
	JpKey string `json:"jpKey"`
	SpinMeta struct {
		Lines int `json:"lines"`
		BetPerLine int64 `json:"betPerLine"`
		TotalBet int64 `json:"totalBet"`
		SymbolMatrix int64 `json:"symbolMatrix"`
	} `json:"spinMeta"`
	BetMeta struct {
		Bets []interface{} `json:"bets"`
	} `json:"betMeta"`
	Notes []interface{} `json:"notes"`
}

type FundsResponse struct {
	Api string `json:"api"`
	IsSuccess bool `json:"isSuccess"`
	Error string `json:"error"`
	ErrorMsg string `json:"errorMsg"`
	Data struct {
	    UserNick string `json:"userNick"`
		Amount int64 `json:"amount"`
		Denomination int `json:"denomination"`
		MaxWin int64 `json:"maxWin"`
		Currency string `json:"currency"`
	} `json:"data"`
}

type users struct {
	id string
	username string
}

type currency struct {
	id string
	name string
	denomination int
}

// DB:
// - users
// - balances
// - operations (debit, credit)


// validation (secret)

// requests:
// - balance

// - debit
// - credit
// - rollback

const (
	balance, debit, credit = "balance", "debit", "credit"
	rollback, metaData = "rollback", "metaData"

	NO_ERRORS = "NO_ERRORS"
	ALREADY_PROCESSED = "ALREADY_PROCESSED"
	SIGN_NOT_PROVIDED = "SIGN_NOT_PROVIDED"
	INVALID_SIGN = "INVALID_SIGN"
	UNKNOWN_CURRENCY = "UNKNOWN_CURRENCY"
	INSUFFICIENT_BALANCE = "INSUFFICIENT_BALANCE"
	INTERNAL_ERROR = "INTERNAL_ERROR"
)

func gamesProcessorHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req Request

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		fmt.Fprintln(w, "Decoding failed.")
		return
	}

	switch req.Api {
	case balance:
		if err := json.NewEncoder(w).Encode(BalanceResponse {Api: req.Api, Data: struct {
			UserNick string `json:"userNick"`
			Amount int64 `json:"amount"`
			Denomination int `json:"denomination"`
			MaxWin int64 `json:"maxWin"`
			Currency string `json:"currency"`
			UserId string `json:"userId"`
			JpKey string `json:"jpKey"`
		}{
			UserNick: "userNick",
			Amount: 0,
			Denomination: 0,
			MaxWin: 0,
			Currency: "currency",
			UserId: "userId",
			JpKey: "jpKey",
		}}); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	case "debit", "credit":
		if err := json.NewEncoder(w).Encode(FundsResponse {
			Api: req.Api,
			IsSuccess: true,
			Error: "",
			ErrorMsg: NO_ERRORS,
			Data: struct {
				UserNick string `json:"userNick"`
				Amount int64 `json:"amount"`
				Denomination int `json:"denomination"`
				MaxWin int64 `json:"maxWin"`
				Currency string `json:"currency"`
			}{
			UserNick: "userNick",
			Amount: 0,
			Denomination: 0,
			MaxWin: 0,
			Currency: "currency",
		}}); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	case "rollback", "metaData":
		http.Error(w, "Not Implemented", http.StatusNotImplemented)
	default:
		http.Error(w, "Unprocessable Entity", http.StatusUnprocessableEntity)
	}
}

func main() {
	fmt.Println("Platform server started")

	psqlconn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"), os.Getenv("DB_PORT"), os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"), os.Getenv("DB_NAME"))

	db, err := sql.Open("postgres", psqlconn)

	defer db.Close()

	if err != nil {
		fmt.Println(err)
		return
    }


    http.HandleFunc("/open-api-games/v1/games-processor", gamesProcessorHandler)
    http.ListenAndServe(":8080", nil)
}
