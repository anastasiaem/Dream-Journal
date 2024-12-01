;; Dream Journal and Interpretation Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var dream-nonce uint u0)
(define-data-var interpreter-nonce uint u0)

;; Define NFT for dream entries
(define-non-fungible-token dream-nft uint)

;; Maps
(define-map dreams
  { dream-id: uint }
  {
    owner: principal,
    content: (string-utf8 1000),
    timestamp: uint,
    ai-analysis: (string-utf8 500),
    is-public: bool
  }
)

(define-map interpreters
  { address: principal }
  {
    interpreter-id: uint,
    reputation: uint,
    total-interpretations: uint
  }
)

(define-map interpretations
  { dream-id: uint, interpreter-id: uint }
  {
    content: (string-utf8 500),
    timestamp: uint,
    rating: (optional uint)
  }
)

(define-map user-reputation
  { user: principal }
  { score: uint }
)

;; Public Functions

;; Record a new dream
(define-public (record-dream (content (string-utf8 1000)) (is-public bool))
  (let
    (
      (new-dream-id (+ (var-get dream-nonce) u1))
    )
    (try! (nft-mint? dream-nft new-dream-id tx-sender))
    (map-set dreams
      { dream-id: new-dream-id }
      {
        owner: tx-sender,
        content: content,
        timestamp: block-height,
        ai-analysis: u"",
        is-public: is-public
      }
    )
    (var-set dream-nonce new-dream-id)
    (ok new-dream-id)
  )
)

;; Update AI analysis for a dream
(define-public (update-ai-analysis (dream-id uint) (analysis (string-utf8 500)))
  (let
    (
      (dream (unwrap! (map-get? dreams { dream-id: dream-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set dreams
      { dream-id: dream-id }
      (merge dream { ai-analysis: analysis })
    )
    (ok true)
  )
)

;; Register as a dream interpreter
(define-public (register-interpreter)
  (let
    (
      (new-interpreter-id (+ (var-get interpreter-nonce) u1))
    )
    (asserts! (is-none (map-get? interpreters { address: tx-sender })) err-already-exists)
    (map-set interpreters
      { address: tx-sender }
      {
        interpreter-id: new-interpreter-id,
        reputation: u100,
        total-interpretations: u0
      }
    )
    (var-set interpreter-nonce new-interpreter-id)
    (ok new-interpreter-id)
  )
)

;; Provide interpretation for a dream
(define-public (interpret-dream (dream-id uint) (interpretation (string-utf8 500)))
  (let
    (
      (dream (unwrap! (map-get? dreams { dream-id: dream-id }) err-not-found))
      (interpreter (unwrap! (map-get? interpreters { address: tx-sender }) err-unauthorized))
    )
    (asserts! (get is-public dream) err-unauthorized)
    (map-set interpretations
      { dream-id: dream-id, interpreter-id: (get interpreter-id interpreter) }
      {
        content: interpretation,
        timestamp: block-height,
        rating: none
      }
    )
    (map-set interpreters
      { address: tx-sender }
      (merge interpreter
             { total-interpretations: (+ (get total-interpretations interpreter) u1) })
    )
    (ok true)
  )
)

;; Rate an interpretation
(define-public (rate-interpretation (dream-id uint) (interpreter-address principal) (rating uint))
  (let
    (
      (dream (unwrap! (map-get? dreams { dream-id: dream-id }) err-not-found))
      (interpreter (unwrap! (map-get? interpreters { address: interpreter-address }) err-not-found))
      (interpretation (unwrap! (map-get? interpretations { dream-id: dream-id, interpreter-id: (get interpreter-id interpreter) }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner dream)) err-unauthorized)
    (asserts! (and (>= rating u1) (<= rating u5)) err-unauthorized)
    (map-set interpretations
      { dream-id: dream-id, interpreter-id: (get interpreter-id interpreter) }
      (merge interpretation { rating: (some rating) })
    )
    ;; Update interpreter reputation
    (map-set interpreters
      { address: interpreter-address }
      (merge interpreter
             { reputation: (/ (+ (* (get reputation interpreter) u9) (* rating u20)) u10) })
    )
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-dream (dream-id uint))
  (map-get? dreams { dream-id: dream-id })
)

(define-read-only (get-interpreter (address principal))
  (map-get? interpreters { address: address })
)

(define-read-only (get-interpretation (dream-id uint) (interpreter-id uint))
  (map-get? interpretations { dream-id: dream-id, interpreter-id: interpreter-id })
)

(define-read-only (get-user-reputation (user principal))
  (default-to { score: u100 } (map-get? user-reputation { user: user }))
)
