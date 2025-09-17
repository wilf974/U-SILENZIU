import bcrypt from 'bcryptjs'
import jwt, { SignOptions } from 'jsonwebtoken'

const DEFAULT_JWT_EXPIRATION = '1h'
export const ADMIN_TOKEN_COOKIE = 'admin_token'

function getJwtSecret(): string {
  const secret = process.env.JWT_SECRET || process.env.SESSION_SECRET

  if (!secret) {
    throw new Error('JWT_SECRET (or SESSION_SECRET) is not defined')
  }

  return secret
}

export async function hashPassword(password: string): Promise<string> {
  const salt = await bcrypt.genSalt(10)
  return bcrypt.hash(password, salt)
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash)
}

export interface TokenPayload {
  sub: string
  username: string
  role: string
}

export function createAdminToken(payload: TokenPayload, options?: SignOptions): string {
  const secret = getJwtSecret()
  const expiresIn = (options?.expiresIn ?? process.env.JWT_EXPIRES_IN ?? DEFAULT_JWT_EXPIRATION) as SignOptions['expiresIn']

  const signOptions: SignOptions = {
    ...(options ?? {}),
    expiresIn,
  }

  return jwt.sign(payload, secret, signOptions)
}

export function verifyAdminToken(token: string): TokenPayload {
  const secret = getJwtSecret()
  const decoded = jwt.verify(token, secret)

  if (typeof decoded === 'string') {
    throw new Error('Invalid token payload')
  }

  return decoded as TokenPayload
}

