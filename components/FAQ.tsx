'use client'

import React, { useState } from 'react'
import { ChevronDown, ChevronUp, HelpCircle } from 'lucide-react'

/**
 * Composant FAQ (Foire aux Questions)
 * U Silenziu - Septembre 2025
 */
export default function FAQ() {
  const [openItems, setOpenItems] = useState<number[]>([])

  const faqItems = [
    {
      question: "Qu'est-ce qu'une rage room ?",
      answer: "Une rage room est un espace sécurisé où vous pouvez libérer votre stress en détruisant des objets. C'est une activité thérapeutique et libératrice qui permet d'évacuer les tensions accumulées dans un environnement contrôlé et sécurisé."
    },
    {
      question: "Est-ce que c'est sécurisé ?",
      answer: "Absolument ! Nous fournissons un équipement de protection complet (casque, gants, chaussures de sécurité, combinaison) et un briefing de sécurité obligatoire. Tous nos objets sont sélectionnés pour être sûrs à détruire et nos salles sont conçues pour minimiser les risques."
    },
    {
      question: "Quel âge minimum pour participer ?",
      answer: "L'âge minimum est de 16 ans avec autorisation parentale, et 18 ans sans accompagnement. Les mineurs doivent être accompagnés d'un adulte responsable qui signe une décharge."
    },
    {
      question: "Combien de personnes peuvent participer ?",
      answer: "Cela dépend de la salle choisie. Nos salles accueillent entre 2 et 10 personnes maximum. Nous recommandons des groupes de 2-4 personnes pour une expérience optimale."
    },
    {
      question: "Que peut-on détruire ?",
      answer: "Nous fournissons une variété d'objets sécurisés : assiettes, verres, bouteilles, petits meubles, électroménager, etc. Tous les objets sont préparés pour être détruits en toute sécurité. Vous pouvez aussi apporter vos propres objets (sous réserve d'approbation)."
    },
    {
      question: "Faut-il réserver à l'avance ?",
      answer: "Oui, la réservation est obligatoire. Vous pouvez réserver en ligne sur notre site ou nous appeler. Nous recommandons de réserver au moins 24h à l'avance, surtout pour les weekends."
    },
    {
      question: "Que se passe-t-il si je me blesse ?",
      answer: "Bien que très rare grâce à notre équipement de protection, nous avons un protocole de sécurité strict. Un membre de notre équipe surveille chaque session et peut intervenir immédiatement. Nous avons également une trousse de premiers secours sur place."
    },
    {
      question: "Peut-on annuler ou reporter ?",
      answer: "Oui, vous pouvez annuler ou reporter jusqu'à 24h avant votre séance. Les annulations de dernière minute sont facturées à 50%. En cas de force majeure, contactez-nous directement."
    },
    {
      question: "Y a-t-il de la musique ?",
      answer: "Oui ! Nous avons une playlist énergique pour accompagner votre session. Vous pouvez aussi apporter votre propre musique. L'ambiance sonore fait partie intégrante de l'expérience U Silenziu."
    },
    {
      question: "Que se passe-t-il après la séance ?",
      answer: "Après votre session, nous vous aidons à retirer l'équipement et vous proposons un moment de détente. Vous repartez avec un sentiment de libération et de bien-être. Nous nous occupons du nettoyage de la salle."
    }
  ]

  const toggleItem = (index: number) => {
    setOpenItems(prev => 
      prev.includes(index) 
        ? prev.filter(item => item !== index)
        : [...prev, index]
    )
  }

  return (
    <section id="faq" className="section-container bg-black py-20">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold mb-4">
            <span className="text-white">Foire aux </span>
            <span className="text-gradient-kaki">Questions</span>
          </h2>
          <p className="text-gray-400 max-w-2xl mx-auto">
            Trouvez les réponses aux questions les plus fréquentes sur l'expérience U Silenziu.
          </p>
        </div>

        {/* FAQ Items */}
        <div className="space-y-4">
          {faqItems.map((item, index) => {
            const isOpen = openItems.includes(index)
            
            return (
              <div 
                key={index}
                className="bg-gray-900 border border-kaki-800/30 rounded-lg overflow-hidden hover:border-kaki-600/50 transition-all duration-300"
              >
                {/* Question */}
                <button
                  onClick={() => toggleItem(index)}
                  className="w-full px-6 py-4 text-left flex items-center justify-between hover:bg-gray-800/50 transition-colors duration-200"
                >
                  <div className="flex items-center gap-3">
                    <HelpCircle className="w-5 h-5 text-kaki-400 flex-shrink-0" />
                    <span className="text-white font-medium text-lg">
                      {item.question}
                    </span>
                  </div>
                  
                  <div className="flex-shrink-0 ml-4">
                    {isOpen ? (
                      <ChevronUp className="w-5 h-5 text-kaki-400" />
                    ) : (
                      <ChevronDown className="w-5 h-5 text-kaki-400" />
                    )}
                  </div>
                </button>

                {/* Answer */}
                {isOpen && (
                  <div className="px-6 pb-4 border-t border-kaki-800/30">
                    <p className="text-gray-300 leading-relaxed pt-4">
                      {item.answer}
                    </p>
                  </div>
                )}
              </div>
            )
          })}
        </div>

        {/* Call to action */}
        <div className="text-center mt-16">
          <p className="text-gray-400 mb-6">
            Vous avez d'autres questions ?
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a 
              href="/contact"
              className="btn-kaki inline-flex items-center gap-2"
            >
              <span>Nous contacter</span>
            </a>
            <a 
              href="/reservation"
              className="btn-kaki-outline inline-flex items-center gap-2"
            >
              <span>Réserver une séance</span>
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}