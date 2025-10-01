import React from 'react'

/**
 * Page des Conditions Générales de Vente
 * @returns JSX.Element
 */
export default function CGVPage() {
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <h1 className="text-3xl font-bold mb-8 text-center">Conditions Générales de Vente</h1>
        
        <div className="space-y-6">
          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">1. Objet</h2>
            <p className="text-gray-300 leading-relaxed">
              Les présentes conditions générales de vente régissent les relations contractuelles entre U Silenziu 
              et ses clients concernant la réservation et l'utilisation des salles de défoulement.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">2. Services proposés</h2>
            <p className="text-gray-300 leading-relaxed">
              U Silenziu propose des salles de défoulement équipées pour la destruction d'objets dans un cadre sécurisé. 
              Les services incluent la mise à disposition d'équipements de protection, de matériel de destruction 
              et d'instructions de sécurité.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">3. Réservations</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• Les réservations s'effectuent en ligne via notre site web</p>
              <p>• Toute réservation est soumise à disponibilité</p>
              <p>• Le paiement est requis pour confirmer la réservation</p>
              <p>• Un numéro de réservation unique est attribué à chaque commande</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">4. Tarifs et paiement</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• Les tarifs sont indiqués en euros TTC</p>
              <p>• Le paiement s'effectue en ligne via Payplug</p>
              <p>• Aucun remboursement n'est possible après utilisation du service</p>
              <p>• Les tarifs peuvent être modifiés sans préavis</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">5. Annulation et modification</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• Annulation gratuite jusqu'à 24h avant la réservation</p>
              <p>• Annulation entre 24h et 2h : 50% de frais</p>
              <p>• Annulation moins de 2h avant : aucun remboursement</p>
              <p>• Les modifications sont soumises à disponibilité</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">6. Responsabilité</h2>
            <p className="text-gray-300 leading-relaxed">
              Le client s'engage à respecter les consignes de sécurité et à utiliser les équipements 
              conformément aux instructions. U Silenziu décline toute responsabilité en cas de non-respect 
              des règles de sécurité.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">7. Données personnelles</h2>
            <p className="text-gray-300 leading-relaxed">
              Les données personnelles collectées sont traitées conformément à notre politique de confidentialité. 
              Elles sont utilisées uniquement pour la gestion des réservations et la communication avec le client.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">8. Droit applicable</h2>
            <p className="text-gray-300 leading-relaxed">
              Les présentes conditions sont soumises au droit français. En cas de litige, les tribunaux 
              français seront compétents.
            </p>
          </section>

          <section className="pt-6 border-t border-gray-700">
            <p className="text-sm text-gray-400">
              Dernière mise à jour : {new Date().toLocaleDateString('fr-FR')}
            </p>
          </section>
        </div>
      </div>
    </div>
  )
}