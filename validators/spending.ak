use aiken/crypto.{VerificationKeyHash}
use types/datum.{MyDatum}
use aiken/option
use aiken/interval.{Finite}
use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}

validator day_3_spending(admin: VerificationKeyHash){
    spend(datum: Option<MyDatum>, _redeemer: Data, _output_reference: OutputReference, tx: Transaction){
         expect Finite(now) = tx.validity_range.lower_bound.bound_type
        let my_datum = datum |> option.or_else(MyDatum{beneficiary: admin, deadline: now})
        and{
        (tx.extra_signatories |> list.has(my_datum.beneficiary))?,
        (now >= my_datum.deadline)?,
        }
    }

    else(_){
        fail
    }
}

test day_3_spending_test(){
    let admin = "0"
    let beneficiary = "1"
    let now = 17450780350000

    let datum = MyDatum {beneficiary, deadline: now}
    let reedemer = 0

    let o_ref = OutputReference("", 0)

    let tx =Transaction{
        ..transaction.placeholder,
        extra_signatories: [beneficiary],
        validity_range: interval.between(now, now + 15 * 60_000)
    }

    day_3_spending.spend(admin, Some(datum), reedemer, o_ref, tx)
}