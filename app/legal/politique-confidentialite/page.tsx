import React from 'react'

/**
 * Page de la Politique de Confidentialité
 * @returns JSX.Element
 */
export default function PolitiqueConfidentialitePage() {
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <h1 className="text-3xl font-bold mb-8 text-center">Politique de Confidentialité</h1>
        
        <div className="space-y-6">
          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">1. Collecte des données</h2>
            <p className="text-gray-300 leading-relaxed mb-4">
              U Silenziu collecte les données personnelles suivantes lors de vos réservations :
            </p>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• <strong>Données d'identification :</strong> nom, prénom, email, téléphone</p>
              <p>• <strong>Données de réservation :</strong> date, heure, nombre de personnes</p>
              <p>• <strong>Données de paiement :</strong> informations de facturation (via Payplug)</p>
              <p>• <strong>Données de navigation :</strong> cookies, adresse IP, pages visitées</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">2. Finalités du traitement</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• Gestion des réservations et des paiements</p>
              <p>• Communication avec les clients</p>
              <p>• Envoi de confirmations et rappels</p>
              <p>• Amélioration de nos services</p>
              <p>• Respect des obligations légales</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">3. Base légale</h2>
            <p className="text-gray-300 leading-relaxed">
              Le traitement de vos données personnelles est basé sur l'exécution du contrat de réservation 
              et notre intérêt légitime à fournir un service de qualité.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">4. Conservation des données</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• <strong>Données de réservation :</strong> 3 ans après la dernière utilisation</p>
              <p>• <strong>Données de facturation :</strong> 10 ans (obligation légale)</p>
              <p>• <strong>Données de marketing :</strong> jusqu'à désinscription</p>
              <p>• <strong>Cookies :</strong> 13 mois maximum</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">5. Partage des données</h2>
            <p className="text-gray-300 leading-relaxed mb-4">
              Vos données personnelles ne sont pas vendues à des tiers. Elles peuvent être partagées avec :
            </p>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• <strong>Payplug :</strong> pour le traitement des paiements</p>
              <p>• <strong>Prestataires techniques :</strong> hébergement, maintenance</p>
              <p>• <strong>Autorités compétentes :</strong> en cas d'obligation légale</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">6. Sécurité des données</h2>
            <p className="text-gray-300 leading-relaxed">
              Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger 
              vos données contre la perte, l'utilisation abusive, l'accès non autorisé, la divulgation, 
              l'altération ou la destruction.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">7. Vos droits</h2>
            <p className="text-gray-300 leading-relaxed mb-4">
              Conformément au RGPD, vous disposez des droits suivants :
            </p>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>• <strong>Droit d'accès :</strong> consulter vos données</p>
              <p>• <strong>Droit de rectification :</strong> corriger vos données</p>
              <p>• <strong>Droit d'effacement :</strong> supprimer vos données</p>
              <p>• <strong>Droit à la portabilité :</strong> récupérer vos données</p>
              <p>• <strong>Droit d'opposition :</strong> vous opposer au traitement</p>
              <p>• <strong>Droit de limitation :</strong> limiter le traitement</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">8. Exercice de vos droits</h2>
            <p className="text-gray-300 leading-relaxed">
              Pour exercer vos droits, contactez-nous à : <strong>info@usilenziu.com</strong><br/>
              Nous vous répondrons dans un délai d'un mois.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">9. Réclamations</h2>
            <p className="text-gray-300 leading-relaxed">
              Si vous estimez que vos droits ne sont pas respectés, vous pouvez introduire une réclamation 
              auprès de la CNIL (Commission Nationale de l'Informatique et des Libertés).
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">10. Modifications</h2>
            <p className="text-gray-300 leading-relaxed">
              Cette politique de confidentialité peut être modifiée à tout moment. Les modifications 
              importantes vous seront notifiées par email.
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
