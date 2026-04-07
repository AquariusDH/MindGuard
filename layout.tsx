import Link from 'next/link'
import { Logo } from '@/components/icons/Logo'

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-blue-50/30 to-stone-50 flex flex-col">
      {/* Header */}
      <header className="px-6 py-5">
        <Link href="/" aria-label="MindGuard home">
          <Logo size="sm" />
        </Link>
      </header>

      {/* Main content */}
      <main className="flex-1 flex items-center justify-center px-6 py-12">
        {children}
      </main>

      {/* Footer */}
      <footer className="px-6 py-5 text-center">
        <p className="text-xs text-stone-400">
          MindGuard is not a medical service.{' '}
          <Link href="/safety" className="underline hover:text-stone-600">
            Safety info
          </Link>
          {' · '}
          <Link href="/privacy" className="underline hover:text-stone-600">
            Privacy
          </Link>
          {' · '}
          <Link href="/terms" className="underline hover:text-stone-600">
            Terms
          </Link>
        </p>
        <p className="text-xs text-stone-400 mt-1">
          In crisis? Call or text{' '}
          <a href="tel:988" className="font-semibold text-stone-600">988</a>
        </p>
      </footer>
    </div>
  )
}
