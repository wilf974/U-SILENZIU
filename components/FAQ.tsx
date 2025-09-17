'use client'

import { useState } from 'react'
import { ChevronDown, ChevronUp } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'

/**
 * Affiche la section "FAQ" uniquement si la section homepage 'faq' est active.
 */
const FAQ = () => {
  const [openItems, setOpenItems] = useState<number[]>([])
  const router = useRouter()
  const { getSectionByKey, getSectionContent, loading } = useHomepageSections()
  const section = getSectionByKey('faq')
  const content = getSectionContent('faq')

  // if (loading) return null
  // Toujours afficher la section FAQ même si pas trouvée dans la base
  // if (!section) return null

  const toggleItem = (index: number) => {
    setOpenItems(prev => 
      prev.includes(index) 
        ? prev.filter(item => item !== index)
        : [...prev, index]
    )
  }

  const scrollToContact = () => {
    const contactSection = document.getElementById('contact')
    if (contactSection) {
      contactSection.scrollIntoView({ behavior: 'smooth' })
    }
  }

  const handleReservation = () => {
    router.push('/reservation')
  }

  // Récupérer les FAQs depuis la base de données ou utiliser les données par défaut
  const faqs = content?.questions || [
    {
      question: 'C\'est quoi une salle de défoulement ?',
      answer: 'Une salle de défoulement est exactement ce que son nom indique : un endroit où l\'on peut se défouler en toute liberté. L\'idée est de fournir un environnement sûr et contrôlé où il est permis de casser et briser des objets sans devoir nettoyer après. Non seulement c\'est une excellente thérapie pour soulager le stress, mais c\'est aussi une expérience extrêmement amusante !'
    },
    {
      question: 'Comment m\'habiller pour ma séance de défoulement ?',
      answer: 'Nous vous recommandons une tenue ample et confortable pour vous sentir à l\'aise et libre de vos mouvements, c\'est physique ! Pour votre sécurité, il est OBLIGATOIRE de venir avec des chaussures fermées et plates de type baskets. En complément, nous vous fournissons une combinaison de sécurité complète et des lunettes de sécurité.'
    },
    {
      question: 'Quels types d\'objets puis-je casser ?',
      answer: 'Selon la formule choisie, vous pourrez casser des bouteilles ou tout autre type d\'objets tels que des verres, des objets multimédia (PC, imprimantes, écrans), du petit électroménager comme grille-pain, machine à café... Les objets varient selon notre arrivage.'
    },
    {
      question: 'Tout ça, c\'est du gaspillage quand même ?',
      answer: 'Pas du tout ! Après chaque séance, les objets cassés sont collectés et pris en charge par des sociétés spécialisées qui s\'occupent du tri, du recyclage, ou de l\'élimination dans le respect des normes en vigueur. Nous faisons en sorte de limiter au maximum l\'impact environnemental de nos activités.'
    },
    {
      question: 'Puis-je écouter ma propre musique pendant ma séance ?',
      answer: 'Bien entendu, chaque pièce est équipée d\'enceintes connectées en Bluetooth, vous pouvez donc vous y connecter et profiter de votre musique préférée !'
    },
    {
      question: 'J\'ai effectué une réservation, puis-je annuler et être remboursé ?',
      answer: 'Dans un souci d\'organisation, les séances annulées ne sont pas remboursables, y compris l\'avoir déjà versé. Cependant, nous vous invitons à nous contacter au plus tôt pour toute demande d\'annulation. Soyez assurés que nous ferons notre possible pour trouver une solution adaptée à votre situation.'
    },
    {
      question: 'Est-il obligatoire de réserver ?',
      answer: 'Il est fortement conseillé de réserver votre session à l\'avance. Cela nous permet de garantir que votre salle soit prête dans les meilleures conditions possibles, avec tout le matériel nécessaire et les équipements adaptés à votre expérience, afin que vous puissiez profiter pleinement de votre moment de défoulement dans un cadre sécurisé et bien organisé.'
    },
    {
      question: 'Je suis une personne à mobilité réduite, puis-je venir ?',
      answer: 'Bien sûr ! Tant que vous êtes en mesure de manier une batte de baseball pour casser des objets, notre équipe sera ravie de vous accueillir et de vous faire profiter de l\'expérience en toute sécurité. L\'ensemble de notre établissement et nos différentes activités sont accessibles aux PMR.'
    },
    {
      question: 'Puis-je laisser mes affaires en toute sécurité ?',
      answer: 'Nous mettons à votre disposition des casiers sécurisés où vous pouvez entreposer vos objets de valeur pendant toute la durée de votre séance. Vous pouvez ainsi profiter pleinement de votre activité sans vous soucier de la sécurité de vos effets personnels.'
    }
  ]

  // Récupérer les informations CTA depuis la base de données ou utiliser les données par défaut
  const ctaInfo = content?.cta_info || {
    title: 'Vous avez encore des questions ?',
    description: 'Notre équipe est là pour vous aider. N\'hésitez pas à nous contacter pour toute information complémentaire.',
    contact_button: 'Nous contacter',
    reservation_button: 'Réserver maintenant'
  }

  return (
    <section className="py-20 bg-dark-surface">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-6">
            {section?.title ? (
              section.title.includes('Questions') ? (
                <span dangerouslySetInnerHTML={{
                  __html: section.title.replace('Questions', '<span class="text-gradient-kaki">Questions</span>')
                }} />
              ) : section.title
            ) : (
              <>Foire aux <span className="text-gradient-kaki">Questions</span></>
            )}
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            {section?.subtitle || 'Retrouvez les réponses aux questions les plus fréquemment posées sur nos services et nos activités.'}
          </p>
        </div>

        <div className="max-w-4xl mx-auto">
          {faqs.map((faq: any, index: number) => (
            <div key={index} className="mb-4">
              <div className="card-dark">
                <button
                  onClick={() => toggleItem(index)}
                  className="w-full flex justify-between items-center text-left focus:outline-none group"
                >
                  <h3 className="text-lg font-semibold text-white group-hover:text-kaki-400 transition-colors">
                    {faq.question}
                  </h3>
                  <div className="ml-4 flex-shrink-0">
                    {openItems.includes(index) ? (
                      <ChevronUp className="text-kaki-500" size={24} />
                    ) : (
                      <ChevronDown className="text-kaki-500" size={24} />
                    )}
                  </div>
                </button>
                
                {openItems.includes(index) && (
                  <div className="mt-4 pt-4 border-t border-kaki-800/30">
                    <p className="text-gray-300 leading-relaxed">
                      {faq.answer}
                    </p>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* Still have questions CTA */}
        <div className="text-center mt-16">
          <div className="card-dark max-w-2xl mx-auto">
            <h3 className="text-2xl font-bold text-white mb-4">
              {ctaInfo.title}
            </h3>
            <p className="text-gray-300 mb-6">
              {ctaInfo.description}
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <button 
                onClick={scrollToContact}
                className="btn-kaki hover:scale-105 transition-transform duration-200"
              >
                {ctaInfo.contact_button}
              </button>
              <button 
                onClick={handleReservation}
                className="btn-kaki-outline hover:scale-105 transition-transform duration-200"
              >
                {ctaInfo.reservation_button}
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default FAQ
