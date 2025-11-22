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
(define-constant ERR_APPRAISER_NOT_AUTHORIZED (err u109))
(define-constant ERR_INVALID_APPRAISAL_VALUE (err u110))
(define-constant ERR_APPRAISER_ALREADY_EXISTS (err u111))
(define-constant ERR_PROPERTY_NOT_FOR_RENT (err u112))
(define-constant ERR_RENTAL_ALREADY_EXISTS (err u113))
(define-constant ERR_INVALID_RENTAL_PERIOD (err u114))
(define-constant ERR_RENT_NOT_DUE (err u115))
(define-constant ERR_NOT_TENANT (err u116))
(define-constant ERR_RENTAL_EXPIRED (err u117))

;; Insurance Error Constants
(define-constant ERR_INSURANCE_NOT_FOUND (err u301))
(define-constant ERR_INSURANCE_EXPIRED (err u302))
(define-constant ERR_INSURANCE_ALREADY_EXISTS (err u303))
(define-constant ERR_CLAIM_NOT_FOUND (err u304))
(define-constant ERR_CLAIM_ALREADY_PROCESSED (err u305))
(define-constant ERR_INVALID_COVERAGE_AMOUNT (err u306))
(define-constant ERR_INVALID_PREMIUM (err u307))
(define-constant ERR_UNAUTHORIZED_INSURANCE (err u308))

;; Document Registry Error Constants
(define-constant ERR_DOC_NOT_PROPERTY_OWNER (err u401))
(define-constant ERR_DOC_PROPERTY_NOT_FOUND (err u402))
(define-constant ERR_DOC_EXISTS (err u403))
(define-constant ERR_DOC_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_REVOKED (err u405))

(define-data-var property-id-counter uint u1)
(define-data-var registry-fee uint u1000000)
(define-data-var transfer-fee-percent uint u2)
(define-data-var appraisal-id-counter uint u1)
(define-data-var rental-id-counter uint u1)

;; Insurance counters
(define-data-var policy-id-counter uint u1)
(define-data-var claim-id-counter uint u1)
(define-data-var payment-id-counter uint u1)

;; Document Registry counters
(define-data-var doc-id-counter uint u1)

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

(define-map authorized-appraisers
    { appraiser: principal }
    {
        authorized-by: principal,
        authorization-date: uint,
        is-active: bool,
        license-number: (string-ascii 50),
    }
)

(define-map property-appraisals
    {
        property-id: uint,
        appraisal-id: uint,
    }
    {
        appraiser: principal,
        appraisal-value: uint,
        appraisal-date: uint,
        confidence-level: uint,
        notes: (string-ascii 200),
    }
)

(define-map rental-listings
    { property-id: uint }
    {
        landlord: principal,
        rent-amount: uint,
        rental-period: uint,
        deposit-amount: uint,
        is-available: bool,
        listing-date: uint,
    }
)

(define-map rental-agreements
    { rental-id: uint }
    {
        property-id: uint,
        landlord: principal,
        tenant: principal,
        rent-amount: uint,
        rental-period: uint,
        deposit-amount: uint,
        start-date: uint,
        end-date: uint,
        last-payment-date: uint,
        next-payment-due: uint,
        is-active: bool,
    }
)

;; Insurance Policy Storage
(define-map insurance-policies
    {
        property-id: uint,
        policy-id: uint,
    }
    {
        provider: (string-ascii 100),
        policy-holder: principal,
        coverage-amount: uint,
        premium-amount: uint,
        start-date: uint,
        end-date: uint,
        status: (string-ascii 20),
        created-at: uint,
    }
)

;; Insurance Claims Tracking
(define-map insurance-claims
    {
        property-id: uint,
        claim-id: uint,
    }
    {
        policy-id: uint,
        claimant: principal,
        claim-amount: uint,
        claim-reason: (string-ascii 500),
        claim-date: uint,
        status: (string-ascii 20),
        processed-date: (optional uint),
        approved-amount: (optional uint),
    }
)

;; Premium Payment History
(define-map premium-payments
    {
        property-id: uint,
        policy-id: uint,
        payment-id: uint,
    }
    {
        payer: principal,
        amount: uint,
        payment-date: uint,
        period-covered: (string-ascii 50),
    }
)

(define-map active-policy-index
    { property-id: uint }
    { policy-id: uint }
)

;; Document Registry Storage
(define-map property-doc-counts
    { property-id: uint }
    { count: uint }
)

(define-map property-documents
    {
        property-id: uint,
        doc-id: uint,
    }
    {
        hash: (buff 32),
        doc-type: (string-ascii 32),
        uri: (string-ascii 256),
        added-by: principal,
        added-at: uint,
        revoked: bool,
    }
)

(define-map property-doc-hash-index
    {
        property-id: uint,
        hash: (buff 32),
    }
    { doc-id: uint }
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

(define-read-only (get-appraiser-info (appraiser principal))
    (map-get? authorized-appraisers { appraiser: appraiser })
)

(define-read-only (get-property-appraisal
        (property-id uint)
        (appraisal-id uint)
    )
    (map-get? property-appraisals {
        property-id: property-id,
        appraisal-id: appraisal-id,
    })
)

(define-read-only (get-appraisal-count)
    (- (var-get appraisal-id-counter) u1)
)

(define-read-only (get-rental-listing (property-id uint))
    (map-get? rental-listings { property-id: property-id })
)

(define-read-only (get-rental-agreement (rental-id uint))
    (map-get? rental-agreements { rental-id: rental-id })
)

(define-read-only (get-rental-count)
    (- (var-get rental-id-counter) u1)
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

(define-public (authorize-appraiser
        (appraiser principal)
        (license-number (string-ascii 50))
    )
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts!
            (is-none (map-get? authorized-appraisers { appraiser: appraiser }))
            ERR_APPRAISER_ALREADY_EXISTS
        )

        (map-set authorized-appraisers { appraiser: appraiser } {
            authorized-by: tx-sender,
            authorization-date: stacks-block-height,
            is-active: true,
            license-number: license-number,
        })
        (ok true)
    )
)

(define-public (deactivate-appraiser (appraiser principal))
    (let ((appraiser-info (unwrap! (map-get? authorized-appraisers { appraiser: appraiser })
            ERR_APPRAISER_NOT_AUTHORIZED
        )))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)

        (map-set authorized-appraisers { appraiser: appraiser }
            (merge appraiser-info { is-active: false })
        )
        (ok true)
    )
)

(define-public (submit-appraisal
        (property-id uint)
        (appraisal-value uint)
        (confidence-level uint)
        (notes (string-ascii 200))
    )
    (let (
            (appraiser-info (unwrap! (map-get? authorized-appraisers { appraiser: tx-sender })
                ERR_APPRAISER_NOT_AUTHORIZED
            ))
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (appraisal-id (var-get appraisal-id-counter))
        )
        (asserts! (get is-active appraiser-info) ERR_APPRAISER_NOT_AUTHORIZED)
        (asserts! (> appraisal-value u0) ERR_INVALID_APPRAISAL_VALUE)
        (asserts! (<= confidence-level u100) ERR_INVALID_APPRAISAL_VALUE)

        (map-set property-appraisals {
            property-id: property-id,
            appraisal-id: appraisal-id,
        } {
            appraiser: tx-sender,
            appraisal-value: appraisal-value,
            appraisal-date: stacks-block-height,
            confidence-level: confidence-level,
            notes: notes,
        })

        (var-set appraisal-id-counter (+ appraisal-id u1))
        (ok appraisal-id)
    )
)

(define-public (list-property-for-rent
        (property-id uint)
        (rent-amount uint)
        (rental-period uint)
        (deposit-amount uint)
    )
    (let ((property (unwrap! (map-get? properties { property-id: property-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (> rent-amount u0) ERR_INVALID_PRICE)
        (asserts! (> rental-period u0) ERR_INVALID_RENTAL_PERIOD)
        (asserts! (> deposit-amount u0) ERR_INVALID_PRICE)

        (map-set rental-listings { property-id: property-id } {
            landlord: tx-sender,
            rent-amount: rent-amount,
            rental-period: rental-period,
            deposit-amount: deposit-amount,
            is-available: true,
            listing-date: stacks-block-height,
        })
        (ok true)
    )
)

(define-public (remove-rental-listing (property-id uint))
    (let ((rental-listing (unwrap! (map-get? rental-listings { property-id: property-id })
            ERR_PROPERTY_NOT_FOR_RENT
        )))
        (asserts! (is-eq (get landlord rental-listing) tx-sender) ERR_NOT_OWNER)

        (map-set rental-listings { property-id: property-id }
            (merge rental-listing { is-available: false })
        )
        (ok true)
    )
)

(define-public (rent-property (property-id uint))
    (let (
            (rental-listing (unwrap! (map-get? rental-listings { property-id: property-id })
                ERR_PROPERTY_NOT_FOR_RENT
            ))
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (rental-id (var-get rental-id-counter))
            (current-height stacks-block-height)
            (end-date (+ current-height (get rental-period rental-listing)))
            (next-payment-due (+ current-height (get rental-period rental-listing)))
            (total-upfront (+ (get rent-amount rental-listing)
                (get deposit-amount rental-listing)
            ))
        )
        (asserts! (get is-available rental-listing) ERR_PROPERTY_NOT_FOR_RENT)
        (asserts! (not (is-eq tx-sender (get landlord rental-listing)))
            ERR_CANNOT_BUY_OWN_PROPERTY
        )

        (try! (stx-transfer? total-upfront tx-sender (get landlord rental-listing)))

        (map-set rental-agreements { rental-id: rental-id } {
            property-id: property-id,
            landlord: (get landlord rental-listing),
            tenant: tx-sender,
            rent-amount: (get rent-amount rental-listing),
            rental-period: (get rental-period rental-listing),
            deposit-amount: (get deposit-amount rental-listing),
            start-date: current-height,
            end-date: end-date,
            last-payment-date: current-height,
            next-payment-due: next-payment-due,
            is-active: true,
        })

        (map-set rental-listings { property-id: property-id }
            (merge rental-listing { is-available: false })
        )

        (var-set rental-id-counter (+ rental-id u1))
        (ok rental-id)
    )
)

(define-public (pay-rent (rental-id uint))
    (let (
            (rental-agreement (unwrap! (map-get? rental-agreements { rental-id: rental-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq tx-sender (get tenant rental-agreement)) ERR_NOT_TENANT)
        (asserts! (get is-active rental-agreement) ERR_RENTAL_EXPIRED)
        (asserts! (>= current-height (get next-payment-due rental-agreement))
            ERR_RENT_NOT_DUE
        )
        (asserts! (<= current-height (get end-date rental-agreement))
            ERR_RENTAL_EXPIRED
        )

        (try! (stx-transfer? (get rent-amount rental-agreement) tx-sender
            (get landlord rental-agreement)
        ))

        (map-set rental-agreements { rental-id: rental-id }
            (merge rental-agreement {
                last-payment-date: current-height,
                next-payment-due: (+ current-height (get rental-period rental-agreement)),
            })
        )
        (ok true)
    )
)

(define-public (terminate-rental (rental-id uint))
    (let ((rental-agreement (unwrap! (map-get? rental-agreements { rental-id: rental-id })
            ERR_PROPERTY_NOT_FOUND
        )))
        (asserts!
            (or
                (is-eq tx-sender (get landlord rental-agreement))
                (is-eq tx-sender (get tenant rental-agreement))
            )
            ERR_NOT_AUTHORIZED
        )
        (asserts! (get is-active rental-agreement) ERR_RENTAL_EXPIRED)

        (try! (stx-transfer? (get deposit-amount rental-agreement)
            (get landlord rental-agreement) (get tenant rental-agreement)
        ))

        (map-set rental-agreements { rental-id: rental-id }
            (merge rental-agreement { is-active: false })
        )

        (map-set rental-listings { property-id: (get property-id rental-agreement) }
            (merge
                (unwrap-panic (map-get? rental-listings { property-id: (get property-id rental-agreement) })) { is-available: true }
            ))
        (ok true)
    )
)

;; ===== INSURANCE FUNCTIONS =====

(define-public (create-insurance-policy
        (property-id uint)
        (provider (string-ascii 100))
        (coverage-amount uint)
        (premium-amount uint)
        (policy-duration uint)
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (policy-id (var-get policy-id-counter))
            (current-height stacks-block-height)
            (end-date (+ current-height policy-duration))
            (maybe-active (map-get? active-policy-index { property-id: property-id }))
        )
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (> coverage-amount u0) ERR_INVALID_COVERAGE_AMOUNT)
        (asserts! (> premium-amount u0) ERR_INVALID_PREMIUM)
        (asserts! (> policy-duration u0) ERR_INVALID_RENTAL_PERIOD)
        (if (is-some maybe-active)
            (let (
                    (active-id (get policy-id (unwrap-panic maybe-active)))
                    (maybe-policy (map-get? insurance-policies {
                        property-id: property-id,
                        policy-id: active-id,
                    }))
                )
                (if (is-some maybe-policy)
                    (asserts!
                        (not (is-eq (get status (unwrap-panic maybe-policy)) "ACTIVE"))
                        ERR_INSURANCE_ALREADY_EXISTS
                    )
                    true
                )
            )
            true
        )
        (try! (stx-transfer? premium-amount tx-sender CONTRACT_OWNER))
        (map-set insurance-policies {
            property-id: property-id,
            policy-id: policy-id,
        } {
            provider: provider,
            policy-holder: tx-sender,
            coverage-amount: coverage-amount,
            premium-amount: premium-amount,
            start-date: current-height,
            end-date: end-date,
            status: "ACTIVE",
            created-at: current-height,
        })
        (let ((initial-payment-id (var-get payment-id-counter)))
            (map-set premium-payments {
                property-id: property-id,
                policy-id: policy-id,
                payment-id: initial-payment-id,
            } {
                payer: tx-sender,
                amount: premium-amount,
                payment-date: current-height,
                period-covered: "INITIAL",
            })
            (var-set payment-id-counter (+ initial-payment-id u1))
        )
        (map-set active-policy-index { property-id: property-id } { policy-id: policy-id })
        (var-set policy-id-counter (+ policy-id u1))
        (ok policy-id)
    )
)

(define-public (submit-insurance-claim
        (property-id uint)
        (policy-id uint)
        (claim-amount uint)
        (claim-reason (string-ascii 500))
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (policy (unwrap!
                (map-get? insurance-policies {
                    property-id: property-id,
                    policy-id: policy-id,
                })
                ERR_INSURANCE_NOT_FOUND
            ))
            (claim-id (var-get claim-id-counter))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (is-eq (get policy-holder policy) tx-sender)
            ERR_UNAUTHORIZED_INSURANCE
        )
        (asserts! (is-eq (get status policy) "ACTIVE") ERR_INSURANCE_EXPIRED)
        (asserts! (<= current-height (get end-date policy)) ERR_INSURANCE_EXPIRED)
        (asserts! (> claim-amount u0) ERR_INVALID_PRICE)
        (asserts! (<= claim-amount (get coverage-amount policy))
            ERR_INVALID_COVERAGE_AMOUNT
        )

        ;; Create claim
        (map-set insurance-claims {
            property-id: property-id,
            claim-id: claim-id,
        } {
            policy-id: policy-id,
            claimant: tx-sender,
            claim-amount: claim-amount,
            claim-reason: claim-reason,
            claim-date: current-height,
            status: "PENDING",
            processed-date: none,
            approved-amount: none,
        })

        (var-set claim-id-counter (+ claim-id u1))
        (ok claim-id)
    )
)

(define-public (process-insurance-claim
        (property-id uint)
        (claim-id uint)
        (approved bool)
        (approved-amount (optional uint))
    )
    (let (
            (claim (unwrap!
                (map-get? insurance-claims {
                    property-id: property-id,
                    claim-id: claim-id,
                })
                ERR_CLAIM_NOT_FOUND
            ))
            (policy (unwrap!
                (map-get? insurance-policies {
                    property-id: property-id,
                    policy-id: (get policy-id claim),
                })
                ERR_INSURANCE_NOT_FOUND
            ))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (asserts! (is-eq (get status claim) "PENDING")
            ERR_CLAIM_ALREADY_PROCESSED
        )

        (if approved
            (begin
                (let ((payout-amount (default-to (get claim-amount claim) approved-amount)))
                    (asserts! (<= payout-amount (get coverage-amount policy))
                        ERR_INVALID_COVERAGE_AMOUNT
                    )
                    (try! (stx-transfer? payout-amount CONTRACT_OWNER
                        (get claimant claim)
                    ))

                    (map-set insurance-claims {
                        property-id: property-id,
                        claim-id: claim-id,
                    }
                        (merge claim {
                            status: "APPROVED",
                            processed-date: (some current-height),
                            approved-amount: (some payout-amount),
                        })
                    )
                )
            )
            (map-set insurance-claims {
                property-id: property-id,
                claim-id: claim-id,
            }
                (merge claim {
                    status: "REJECTED",
                    processed-date: (some current-height),
                    approved-amount: none,
                })
            )
        )
        (ok true)
    )
)

(define-public (cancel-insurance-policy
        (property-id uint)
        (policy-id uint)
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_PROPERTY_NOT_FOUND
            ))
            (policy (unwrap!
                (map-get? insurance-policies {
                    property-id: property-id,
                    policy-id: policy-id,
                })
                ERR_INSURANCE_NOT_FOUND
            ))
        )
        (asserts! (is-eq (get owner property) tx-sender) ERR_NOT_OWNER)
        (asserts! (is-eq (get policy-holder policy) tx-sender)
            ERR_UNAUTHORIZED_INSURANCE
        )
        (asserts! (is-eq (get status policy) "ACTIVE") ERR_INSURANCE_EXPIRED)
        (map-set insurance-policies {
            property-id: property-id,
            policy-id: policy-id,
        }
            (merge policy { status: "CANCELLED" })
        )
        (ok true)
    )
)

(define-public (renew-insurance-policy
        (property-id uint)
        (policy-id uint)
        (new-coverage-amount uint)
        (new-premium-amount uint)
        (policy-duration uint)
    )
    (let (
            (policy (unwrap!
                (map-get? insurance-policies {
                    property-id: property-id,
                    policy-id: policy-id,
                })
                ERR_INSURANCE_NOT_FOUND
            ))
            (current-height stacks-block-height)
            (new-end-date (+ current-height policy-duration))
        )
        (asserts! (is-eq (get policy-holder policy) tx-sender)
            ERR_UNAUTHORIZED_INSURANCE
        )
        (asserts! (is-eq (get status policy) "ACTIVE") ERR_INSURANCE_EXPIRED)
        (asserts! (> new-coverage-amount u0) ERR_INVALID_COVERAGE_AMOUNT)
        (asserts! (> new-premium-amount u0) ERR_INVALID_PREMIUM)
        (asserts! (> policy-duration u0) ERR_INVALID_RENTAL_PERIOD)
        (try! (stx-transfer? new-premium-amount tx-sender CONTRACT_OWNER))
        (map-set insurance-policies {
            property-id: property-id,
            policy-id: policy-id,
        }
            (merge policy {
                coverage-amount: new-coverage-amount,
                premium-amount: new-premium-amount,
                start-date: current-height,
                end-date: new-end-date,
                status: "ACTIVE",
            })
        )
        (let ((payment-id (var-get payment-id-counter)))
            (map-set premium-payments {
                property-id: property-id,
                policy-id: policy-id,
                payment-id: payment-id,
            } {
                payer: tx-sender,
                amount: new-premium-amount,
                payment-date: current-height,
                period-covered: "RENEWAL",
            })
            (var-set payment-id-counter (+ payment-id u1))
        )
        (ok true)
    )
)

(define-public (record-premium-payment
        (property-id uint)
        (policy-id uint)
        (period-covered (string-ascii 50))
    )
    (let (
            (policy (unwrap!
                (map-get? insurance-policies {
                    property-id: property-id,
                    policy-id: policy-id,
                })
                ERR_INSURANCE_NOT_FOUND
            ))
            (payment-id (var-get payment-id-counter))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq (get policy-holder policy) tx-sender)
            ERR_UNAUTHORIZED_INSURANCE
        )
        (asserts! (is-eq (get status policy) "ACTIVE") ERR_INSURANCE_EXPIRED)
        (try! (stx-transfer? (get premium-amount policy) tx-sender CONTRACT_OWNER))
        (map-set premium-payments {
            property-id: property-id,
            policy-id: policy-id,
            payment-id: payment-id,
        } {
            payer: tx-sender,
            amount: (get premium-amount policy),
            payment-date: current-height,
            period-covered: period-covered,
        })
        (var-set payment-id-counter (+ payment-id u1))
        (ok payment-id)
    )
)

;; ===== INSURANCE READ-ONLY FUNCTIONS =====

(define-read-only (get-insurance-policy
        (property-id uint)
        (policy-id uint)
    )
    (map-get? insurance-policies {
        property-id: property-id,
        policy-id: policy-id,
    })
)

(define-read-only (get-insurance-claim
        (property-id uint)
        (claim-id uint)
    )
    (map-get? insurance-claims {
        property-id: property-id,
        claim-id: claim-id,
    })
)

(define-read-only (get-premium-payment
        (property-id uint)
        (policy-id uint)
        (payment-id uint)
    )
    (map-get? premium-payments {
        property-id: property-id,
        policy-id: policy-id,
        payment-id: payment-id,
    })
)

(define-read-only (is-policy-active
        (property-id uint)
        (policy-id uint)
    )
    (match (map-get? insurance-policies {
        property-id: property-id,
        policy-id: policy-id,
    })
        policy (and
            (is-eq (get status policy) "ACTIVE")
            (<= stacks-block-height (get end-date policy))
        )
        false
    )
)

(define-read-only (get-policy-coverage
        (property-id uint)
        (policy-id uint)
    )
    (match (map-get? insurance-policies {
        property-id: property-id,
        policy-id: policy-id,
    })
        policy (some (get coverage-amount policy))
        none
    )
)

(define-read-only (get-policy-count)
    (- (var-get policy-id-counter) u1)
)

(define-read-only (get-claim-count)
    (- (var-get claim-id-counter) u1)
)

(define-read-only (get-payment-count)
    (- (var-get payment-id-counter) u1)
)

;; ===== DOCUMENT REGISTRY FUNCTIONS =====

(define-public (add-document
        (property-id uint)
        (doc-hash (buff 32))
        (doc-type (string-ascii 32))
        (uri (string-ascii 256))
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_DOC_PROPERTY_NOT_FOUND
            ))
            (doc-id (var-get doc-id-counter))
            (current-height stacks-block-height)
        )
        (asserts! (is-eq (get owner property) tx-sender)
            ERR_DOC_NOT_PROPERTY_OWNER
        )
        (asserts!
            (is-none (map-get? property-doc-hash-index {
                property-id: property-id,
                hash: doc-hash,
            }))
            ERR_DOC_EXISTS
        )

        ;; Create document record
        (map-set property-documents {
            property-id: property-id,
            doc-id: doc-id,
        } {
            hash: doc-hash,
            doc-type: doc-type,
            uri: uri,
            added-by: tx-sender,
            added-at: current-height,
            revoked: false,
        })

        ;; Add to hash index
        (map-set property-doc-hash-index {
            property-id: property-id,
            hash: doc-hash,
        } { doc-id: doc-id }
        )

        ;; Update document count
        (let ((current-count (default-to { count: u0 }
                (map-get? property-doc-counts { property-id: property-id })
            )))
            (map-set property-doc-counts { property-id: property-id } { count: (+ (get count current-count) u1) })
        )

        (var-set doc-id-counter (+ doc-id u1))
        (ok doc-id)
    )
)

(define-public (revoke-document
        (property-id uint)
        (doc-id uint)
    )
    (let (
            (property (unwrap! (map-get? properties { property-id: property-id })
                ERR_DOC_PROPERTY_NOT_FOUND
            ))
            (document (unwrap!
                (map-get? property-documents {
                    property-id: property-id,
                    doc-id: doc-id,
                })
                ERR_DOC_NOT_FOUND
            ))
        )
        (asserts! (is-eq (get owner property) tx-sender)
            ERR_DOC_NOT_PROPERTY_OWNER
        )
        (asserts! (not (get revoked document)) ERR_ALREADY_REVOKED)

        ;; Update document to revoked status
        (map-set property-documents {
            property-id: property-id,
            doc-id: doc-id,
        }
            (merge document { revoked: true })
        )

        (ok true)
    )
)

;; ===== DOCUMENT REGISTRY READ-ONLY FUNCTIONS =====

(define-read-only (get-document
        (property-id uint)
        (doc-id uint)
    )
    (map-get? property-documents {
        property-id: property-id,
        doc-id: doc-id,
    })
)

(define-read-only (get-doc-count (property-id uint))
    (match (map-get? property-doc-counts { property-id: property-id })
        count-info (get count count-info)
        u0
    )
)

(define-read-only (has-document
        (property-id uint)
        (doc-hash (buff 32))
    )
    (is-some (map-get? property-doc-hash-index {
        property-id: property-id,
        hash: doc-hash,
    }))
)

(define-read-only (get-doc-id-by-hash
        (property-id uint)
        (doc-hash (buff 32))
    )
    (map-get? property-doc-hash-index {
        property-id: property-id,
        hash: doc-hash,
    })
)
