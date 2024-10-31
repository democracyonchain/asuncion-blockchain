use aiken/crypto.{VerificationKeyHash}
type TipoCuenta = Int
// 0 - Cuenta O
// 1 - Cuenta Y

pub type DatumYO {
  firmante_1: VerificationKeyHash,
  firmante_2: VerificationKeyHash,
  tipo_cuenta: TipoCuenta,
}
