(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_PROPERTY_NOT_FOUND (err u101))
(define-constant ERR_PROPERTY_ALREADY_EXISTS (err u102))
(define-constant ERR_NOT_OWNER (err u103))
(define-constant ERR_INVALID_PRICE (err u104))
(define-constant ERR_INSUFFICIENT_FUNDS (err u105))
(define-constant ERR_PROPERTY_NOT_FOR_SALE (err u106))
(define-constant ERR_CANNOT_BUY_OWN_PROPERTY (err u107))
(define-constant ERR_TRANSFER_FAILED (err u108))

(define-data-var property-id-counter uint u1)
(define-data-var registry-fee uint u1000000)
(define-data-var transfer-fee-percent uint u2)

(define-map properties
    { property-id: uint }
    {
        owner: principal,
        location: (string-ascii 100),
        size: uint,
        property-type: (string-ascii 50),
        registration-date: uint,
        last-updated: uint,
        is-verified: bool,
        market-value: (optional uint),
        is-for-sale: bool,
        sale-price: (optional uint),
    }
)

(define-map property-history
    {
        property-id: uint,
        transaction-id: uint,
    }
    {
        from-owner: (optional principal),
        to-owner: principal,
        transaction-type: (string-ascii 20),
        price: (optional uint),
        timestamp: uint,
    }
)

(define-map user-properties
    { owner: principal }
    { property-ids: (list 100 uint) }
)

(define-map property-metadata
    { property-id: uint }
    {
        title-deed-hash: (string-ascii 64),
        survey-hash: (string-ascii 64),
        legal-description: (string-ascii 200),
        zoning: (string-ascii 30),
        tax-id: (string-ascii 50),
    }
)

(define-map verification-requests
    { property-id: uint }
    {
        requester: principal,
        request-date: uint,
        status: (string-ascii 20),
        verifier: (optional principal),
        verification-date: (optional uint),
    }
)

(define-data-var transaction-counter uint u1)

(define-public (register-property
        (location (string-ascii 100))
        (size uint)
        (property-type (string-ascii 50))
        (title-deed-hash (string-ascii 64))
        (survey-hash (string-ascii 64))
        (legal-description (string-ascii 200))
        (zoning (string-ascii 30))
        (tax-id (string-ascii 50))
    )
    (let (
            (property-id (var-get property-id-counter))
            (current-height stacks-block-height)
        )
        (asserts! (> size u0) ERR_INVALID_PRICE)
        (try! (stx-transfer? (var-get registry-fee) tx-sender CONTRACT_OWNER))

        (map-set properties { property-id: property-id } {
            owner: tx-sender,
            location: location,
            size: size,
            property-type: property-type,
            registration-date: current-height,
            last-updated: current-height,
            is-verified: false,
            market-value: none,
            is-for-sale: false,
            sale-price: none,
        })

        (map-set property-metadata { property-id: property-id } {
            title-deed-hash: title-deed-hash,
            survey-hash: survey-hash,
            legal-description: legal-description,
            zoning: zoning,
            tax-id: tax-id,
        })

        (let ((current-properties (default-to { property-ids: (list) }
                (map-get? user-properties { owner: tx-sender })
            )))
            (map-set user-properties { owner: tx-sender } { property-ids: (unwrap-panic (as-max-len?
                (append (get property-ids current-properties) property-id)
                u100
            )) }
            )
        )

        (record-transaction property-id none tx-sender "REGISTRATION" none)
        (var-set property-id-counter (+ property-id u1))
        (ok property-id)
    )
)

(define-public (transfer-property
        (property-id uint)
        (new-owner principal)
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (not (is-eq tx-sender new-owner)) ERR_CANNOT_BUY_OWN_PROPERTY)

        (map-set properties { property-id: property-id }
            (merge property {
                owner: new-owner,
                last-updated: current-height,
                is-for-sale: false,
                sale-price: none,
            })
        )

        (update-user-properties tx-sender property-id false)
        (update-user-properties new-owner property-id true)
        (record-transaction property-id (some tx-sender) new-owner "TRANSFER"
            none
        )
        (ok true)
    )
)

(define-public (list-property-for-sale
        (property-id uint)
        (price uint)
    )
    (let ((property (unwrap! (map-get? properties { property-id: property-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (> price u0) ERR_INVALID_PRICE)

        (map-set properties { property-id: property-id }
            (merge property {
                is-for-sale: true,
                sale-price: (some price),
                last-updated: stacks-block-height,
            })
        )
        (ok true)
    )
)

(define-public (remove-property-from-sale (property-id uint))
    (let ((property (unwrap! (map-get? properties { property-id: property-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)

        (map-set properties { property-id: property-id }
            (merge property {
                is-for-sale: false,
                sale-price: none,
                last-updated: stacks-block-height,
            })
        )
        (ok true)
    )
)

(define-public (purchase-property (property-id uint))
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (sale-price (unwrap! (get sale-price property) ERR_PROPERTY_NOT_FOR_SALE))
            (current-owner (get owner property))
            (transfer-fee (/ (* sale-price (var-get transfer-fee-percent)) u100))
            (owner-payment (- sale-price transfer-fee))
        )
        (asserts! (get is-for-sale property) ERR_PROPERTY_NOT_FOR_SALE)
        (asserts! (not (is-eq tx-sender current-owner))
            ERR_CANNOT_BUY_OWN_PROPERTY
        )

        (try! (stx-transfer? sale-price tx-sender current-owner))
        (try! (stx-transfer? transfer-fee tx-sender CONTRACT_OWNER))

        (map-set properties { property-id: property-id }
            (merge property {
                owner: tx-sender,
                last-updated: stacks-block-height,
                is-for-sale: false,
                sale-price: none,
            })
        )

        (update-user-properties current-owner property-id false)
        (update-user-properties tx-sender property-id true)
        (record-transaction property-id (some current-owner) tx-sender "SALE"
            (some sale-price)
        )
        (ok true)
    )
)

(define-public (update-market-value
        (property-id uint)
        (new-value uint)
    )
    (let ((property (unwrap! (map-get? properties { property-id: property-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)

        (map-set properties { property-id: property-id }
            (merge property {
                market-value: (some new-value),
                last-updated: stacks-block-height,
            })
        )
        (ok true)
    )
)

(define-public (request-verification (property-id uint))
    (let ((property (unwrap! (map-get? properties { property-id: property-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)

        (map-set verification-requests { property-id: property-id } {
            requester: tx-sender,
            request-date: stacks-block-height,
            status: "PENDING",
            verifier: none,
            verification-date: none,
        })
        (ok true)
    )
)

(define-public (verify-property (property-id uint))
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (verification-request (unwrap!
                (map-get? verification-requests { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)

        (map-set properties { property-id: property-id }
            (merge property {
                is-verified: true,
                last-updated: stacks-block-height,
            })
        )

        (map-set verification-requests { property-id: property-id }
            (merge verification-request {
                status: "VERIFIED",
                verifier: (some tx-sender),
                verification-date: (some stacks-block-height),
            })
        )
        (ok true)
    )
)

(define-private (update-user-properties
        (user principal)
        (target-property-id uint)
        (add bool)
    )
    (let (
            (current-properties (default-to { property-ids: (list) }
                (map-get? user-properties { owner: user })
            ))
            (property-list (get property-ids current-properties))
        )
        (if add
            (map-set user-properties { owner: user } { property-ids: (unwrap-panic (as-max-len? (append property-list target-property-id) u100)) })
            (begin
                (map-set user-properties { owner: user } { property-ids: (filter is-not-target-property property-list) })
                true
            )
        )
    )
)

(define-private (is-not-target-property (id uint))
    true
)

(define-private (record-transaction
        (property-id uint)
        (from-owner (optional principal))
        (to-owner principal)
        (transaction-type (string-ascii 20))
        (price (optional uint))
    )
    (let ((transaction-id (var-get transaction-counter)))
        (map-set property-history {
            property-id: property-id,
            transaction-id: transaction-id,
        } {
            from-owner: from-owner,
            to-owner: to-owner,
            transaction-type: transaction-type,
            price: price,
            timestamp: stacks-block-height,
        })
        (var-set transaction-counter (+ transaction-id u1))
    )
)

(define-read-only (get-property (property-id uint))
    (map-get? properties { property-id: property-id })
)

(define-read-only (get-property-metadata (property-id uint))
    (map-get? property-metadata { property-id: property-id })
)

(define-read-only (get-user-properties (owner principal))
    (map-get? user-properties { owner: owner })
)

(define-read-only (get-property-history
        (property-id uint)
        (transaction-id uint)
    )
    (map-get? property-history {
        property-id: property-id,
        transaction-id: transaction-id,
    })
)

(define-read-only (get-verification-request (property-id uint))
    (map-get? verification-requests { property-id: property-id })
)

(define-read-only (get-registry-fee)
    (var-get registry-fee)
)

(define-read-only (get-transfer-fee-percent)
    (var-get transfer-fee-percent)
)

(define-read-only (get-property-count)
    (- (var-get property-id-counter) u1)
)

(define-public (set-registry-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (var-set registry-fee new-fee)
        (ok true)
    )
)

(define-public (set-transfer-fee-percent (new-percent uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (<= new-percent u10) ERR_INVALID_PRICE)
        (var-set transfer-fee-percent new-percent)
        (ok true)
    )
)
