/* func-insert_ipn.sql : FIXME

CODE TO BE PORTED:

CREATE PROCEDURE [dbo].[InsertIPN]

 * InsertIPN () 
 *
 * This procedure inserts a PayPal Instant Payment Notice.
 *
 * Returns  Meaning
 * -------  --------------------------------
 * Rowcount Number of rows inserted
 * Error    Status: 0=success
 * Identity IPN Unique ID
 *
 * Copyright (C) 2002 Hamzei Analytics
 * -----------------------------------------------------------
 * Modification History
 * Date       PI Comments
 * ---------- -- ---------------------------------------------
 * 2003-08-27 Original version by Cypress Productivity Systems
 * 2010-07-03 LB Added try..catch and begin..end transaction

 (
        @business          varchar(50)  = NULL, 
        @receiver_email    varchar(50)  = NULL,
        @item_name         varchar(50)  = NULL,     
        @item_number       varchar(50)  = NULL,     
        @quantity          int          = NULL, 
        @invoice           varchar(50)  = NULL,  
        @custom            varchar(50)  = NULL,  
        @memo              varchar(50)  = NULL, 
        @tax               money        = NULL, 
        @payment_status    varchar(50)  = NULL, 
        @pending_reason    varchar(50)  = NULL, 
        @reason_code       varchar(50)  = NULL, 
        @payment_date      varchar(50)  = NULL, 
        @txn_id            varchar(50)  = NULL,
        @txn_type          varchar(50)  = NULL, 
        @payment_type      varchar(50)  = NULL, 
        @mc_gross          money        = NULL, 
        @mc_fee            money        = NULL, 
        @mc_currency       char(3)      = NULL, 
        @settle_amount     money        = NULL,
        @settle_currency   varchar(50)  = NULL, 
        @exchange_rate     float        = NULL,  
        @payment_gross     money        = NULL, 
        @payment_fee       money        = NULL, 
        @subscr_date       varchar(50)  = NULL, 
        @subscr_effective  varchar(50)  = NULL, 
        @period1           varchar(50)  = NULL, 
        @period2           varchar(50)  = NULL, 
        @period3           varchar(50)  = NULL, 
        @amount1           money        = NULL, 
        @amount2           money        = NULL, 
        @amount3           money        = NULL,
        @mc_amount1        money        = NULL, 
        @mc_amount2        money        = NULL, 
        @mc_amount3        money        = NULL, 
        @recurring         char(1)      = NULL, 
        @reattempt         char(1)      = NULL, 
        @retry_at          varchar(50)  = NULL,
        @recur_times       int          = NULL, 
        @username          varchar(50)  = NULL, 
        @password          varchar(50)  = NULL,  
        @subscr_id         varchar(50)  = NULL, 
        @first_name        varchar(50)  = NULL, 
        @last_name         varchar(50)  = NULL,
        @address_name      varchar(50)  = NULL, 
        @address_street    varchar(50)  = NULL, 
        @address_city      varchar(50)  = NULL, 
        @address_state     varchar(50)  = NULL, 
        @address_zip       varchar(50)  = NULL,
        @address_country   varchar(50)  = NULL, 
        @address_status    varchar(50)  = NULL, 
        @payer_email       varchar(50)  = NULL, 
        @payer_id          varchar(50)  = NULL, 
        @payer_status      varchar(50)  = NULL,
        @notify_version    varchar(8)   = NULL, 
        @verify_sign       varchar(200) = NULL, 
        @post_status       varchar(50)  = NULL, 
        @post_response     varchar(50)  = NULL
) AS
-- Status variables
DECLARE @Rowcount int,
        @Error    int,
        @Identity int
        
    SET NOCOUNT ON

    SELECT
        @Rowcount = 0,
        @Error = 0,
        @Identity = 0
    
    IF (LTRIM(RTRIM(@custom)) = '') SET @custom = NULL

    BEGIN TRY
        BEGIN TRANSACTION
        INSERT IPN (
            business,
            IPNReceived, 
            receiver_email,     
            item_name,     
            item_number,     
            quantity, 
            invoice,  
            custom,  
            memo, 
            tax, 
            payment_status, 
            pending_reason, 
            reason_code, 
            payment_date, 
            txn_id,
            txn_type, 
            payment_type, 
            mc_gross, 
            mc_fee, 
            mc_currency, 
            settle_amount,
            settle_currency, 
            exchange_rate,  
            payment_gross, 
            payment_fee, 
            subscr_date, 
            subscr_effective, 
            period1, 
            period2, 
            period3, 
            amount1, 
            amount2, 
            amount3,
            mc_amount1, 
            mc_amount2, 
            mc_amount3, 
            recurring, 
            reattempt, 
            retry_at,
            recur_times, 
            username, 
            [password],  
            subscr_id, 
            first_name, 
            last_name,
            address_name, 
            address_street, 
            address_city, 
            address_state, 
            address_zip,
            address_country, 
            address_status, 
            payer_email, 
            payer_id, 
            payer_status,
            notify_version, 
            verify_sign, 
            post_status, 
            post_response
        ) VALUES (
            @business, 
            GetDate(),
            @receiver_email,     
            @item_name,     
            @item_number,     
            @quantity, 
            @invoice,  
            @custom,  
            @memo, 
            @tax, 
            @payment_status, 
            @pending_reason, 
            @reason_code, 
            @payment_date, 
            @txn_id,
            @txn_type, 
            @payment_type, 
            @mc_gross, 
            @mc_fee, 
            @mc_currency, 
            @settle_amount,
            @settle_currency, 
            @exchange_rate,  
            @payment_gross, 
            @payment_fee, 
            @subscr_date, 
            @subscr_effective, 
            @period1, 
            @period2, 
            @period3, 
            @amount1, 
            @amount2, 
            @amount3,
            @mc_amount1, 
            @mc_amount2, 
            @mc_amount3, 
            @recurring, 
            @reattempt, 
            @retry_at,
            @recur_times, 
            @username, 
            @password,  
            @subscr_id, 
            @first_name, 
            @last_name,
            @address_name, 
            @address_street, 
            @address_city, 
            @address_state, 
            @address_zip,
            @address_country, 
            @address_status, 
            @payer_email, 
            @payer_id, 
            @payer_status,
            @notify_version, 
            @verify_sign, 
            @post_status, 
            @post_response
        )
        SELECT @Rowcount = @@ROWCOUNT,
               @Error    = @@ERROR,
               @Identity = @@IDENTITY
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        SELECT @Error = ERROR_NUMBER()
        IF (XACT_STATE()) = -1
            ROLLBACK TRANSACTION
        IF (XACT_STATE()) = 1
            COMMIT TRANSACTION          
    END CATCH

    -- Other code here?
    SELECT @Rowcount as 'Rowcount',
           @Error    as 'Error',
           @Identity as 'IPNUID'
    RETURN

GO

*/
