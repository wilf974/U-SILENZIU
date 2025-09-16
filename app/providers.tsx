'use client'

import { SWRConfig } from 'swr'

const fetcher = async (url: string) => {
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error(`Erreur HTTP: ${response.status}`)
  }
  
  return response.json()
}

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher,
        revalidateOnFocus: false,
        revalidateOnReconnect: false,
        dedupingInterval: 10000,
        errorRetryCount: 1,
        onError: (error) => {
          console.error('SWR Error:', error)
        },
      }}
    >
      {children}
    </SWRConfig>
  )
}
