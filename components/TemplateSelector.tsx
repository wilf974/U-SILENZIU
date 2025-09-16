'use client'

import { useState } from 'react'
import { getAllTemplates, getTemplateById, previewTemplate, Template } from '@/lib/templates'
import { FileText, Eye, Check, X } from 'lucide-react'

interface TemplateSelectorProps {
  onTemplateSelect: (template: Template, previewContent: string) => void
  onClose: () => void
}

export default function TemplateSelector({ onTemplateSelect, onClose }: TemplateSelectorProps) {
  const [selectedTemplate, setSelectedTemplate] = useState<Template | null>(null)
  const [templateData, setTemplateData] = useState<Record<string, any>>({})
  const [previewContent, setPreviewContent] = useState<string>('')

  const templates = getAllTemplates()

  const handleTemplateSelect = (template: Template) => {
    setSelectedTemplate(template)
    
    // Initialiser les données avec les valeurs par défaut
    const defaultData: Record<string, any> = {}
    template.variables.forEach(variable => {
      defaultData[variable.name] = variable.defaultValue || ''
    })
    setTemplateData(defaultData)
    
    // Générer la prévisualisation
    const preview = previewTemplate(template.id, defaultData)
    setPreviewContent(preview)
  }

  const handleVariableChange = (variableName: string, value: any) => {
    const newData = { ...templateData, [variableName]: value }
    setTemplateData(newData)
    
    if (selectedTemplate) {
      const preview = previewTemplate(selectedTemplate.id, newData)
      setPreviewContent(preview)
    }
  }

  const handleApplyTemplate = () => {
    if (selectedTemplate) {
      onTemplateSelect(selectedTemplate, previewContent)
    }
  }

  const renderVariableInput = (variable: any) => {
    const value = templateData[variable.name] || ''

    switch (variable.type) {
      case 'text':
        return (
          <input
            type="text"
            value={value}
            onChange={(e) => handleVariableChange(variable.name, e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder={variable.description}
          />
        )
      
      case 'number':
        return (
          <input
            type="number"
            value={value}
            onChange={(e) => handleVariableChange(variable.name, Number(e.target.value))}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder={variable.description}
          />
        )
      
      case 'image':
        return (
          <input
            type="text"
            value={value}
            onChange={(e) => handleVariableChange(variable.name, e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="URL de l'image"
          />
        )
      
      case 'boolean':
        return (
          <input
            type="checkbox"
            checked={Boolean(value)}
            onChange={(e) => handleVariableChange(variable.name, e.target.checked)}
            className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-600 rounded bg-gray-700"
          />
        )
      
      case 'list':
        return (
          <textarea
            value={Array.isArray(value) ? JSON.stringify(value, null, 2) : ''}
            onChange={(e) => {
              try {
                const parsed = JSON.parse(e.target.value)
                handleVariableChange(variable.name, parsed)
              } catch {
                // Ignorer les erreurs de parsing JSON
              }
            }}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            rows={4}
            placeholder="Format JSON: [{'name': 'Valeur', 'description': 'Description'}]"
          />
        )
      
      default:
        return (
          <input
            type="text"
            value={value}
            onChange={(e) => handleVariableChange(variable.name, e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder={variable.description}
          />
        )
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-800 rounded-lg w-full max-w-6xl max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
          <h2 className="text-xl font-semibold text-white">
            Sélectionner un template
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
        
        <div className="p-6">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Liste des templates */}
            <div className="lg:col-span-1">
              <h3 className="text-lg font-medium text-white mb-4">Templates disponibles</h3>
              <div className="space-y-3">
                {templates.map((template) => (
                  <div
                    key={template.id}
                    className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                      selectedTemplate?.id === template.id
                        ? 'border-kaki-500 bg-kaki-900/20'
                        : 'border-gray-600 hover:border-gray-500'
                    }`}
                    onClick={() => handleTemplateSelect(template)}
                  >
                    <div className="flex items-center space-x-3">
                      <FileText className="w-5 h-5 text-kaki-500" />
                      <div className="flex-1">
                        <h4 className="text-white font-medium">{template.name}</h4>
                        <p className="text-sm text-gray-400">{template.description}</p>
                      </div>
                      {selectedTemplate?.id === template.id && (
                        <Check className="w-5 h-5 text-kaki-500" />
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Configuration du template */}
            {selectedTemplate && (
              <div className="lg:col-span-1">
                <h3 className="text-lg font-medium text-white mb-4">
                  Configuration - {selectedTemplate.name}
                </h3>
                <div className="space-y-4">
                  {selectedTemplate.variables.map((variable) => (
                    <div key={variable.name}>
                      <label className="block text-sm font-medium text-gray-300 mb-2">
                        {variable.label}
                        {variable.required && <span className="text-red-500 ml-1">*</span>}
                      </label>
                      {renderVariableInput(variable)}
                      <p className="text-xs text-gray-400 mt-1">{variable.description}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Prévisualisation */}
            <div className="lg:col-span-1">
              <div className="flex items-center space-x-2 mb-4">
                <Eye className="w-5 h-5 text-kaki-500" />
                <h3 className="text-lg font-medium text-white">Prévisualisation</h3>
              </div>
              <div className="border border-gray-600 rounded-lg p-4 bg-gray-900 max-h-96 overflow-y-auto">
                {previewContent ? (
                  <div 
                    className="prose prose-invert prose-sm max-w-none"
                    dangerouslySetInnerHTML={{ __html: previewContent }}
                  />
                ) : (
                  <p className="text-gray-400 text-center py-8">
                    Sélectionnez un template pour voir la prévisualisation
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-3 mt-6 pt-6 border-t border-gray-700">
            <button
              onClick={onClose}
              className="px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-white bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
            >
              Annuler
            </button>
            <button
              onClick={handleApplyTemplate}
              disabled={!selectedTemplate}
              className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Appliquer le template
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
