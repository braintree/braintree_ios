import CardinalMobile

protocol CardinalSessionTestable {

    func configure(_ sessionConfig: CardinalSessionConfiguration)

    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    )
    
    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate)
}

extension CardinalSession: CardinalSessionTestable { }
