import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    console.log("File upload controller connected")
  }

  preview(event) {
    const files = event.target.files
    const fileList = document.getElementById('file-list')
    
    if (!fileList) return
    
    fileList.innerHTML = ''
    
    if (files.length > 0) {
      const listContainer = document.createElement('div')
      listContainer.className = 'space-y-2'
      
      const header = document.createElement('h4')
      header.className = 'text-sm font-medium text-gray-700'
      header.textContent = 'Selected files:'
      listContainer.appendChild(header)
      
      Array.from(files).forEach((file, index) => {
        const fileItem = document.createElement('div')
        fileItem.className = 'flex items-center justify-between p-2 bg-gray-50 rounded'
        
        const fileInfo = document.createElement('div')
        fileInfo.className = 'flex items-center space-x-2'
        
        const icon = document.createElement('svg')
        icon.className = 'h-5 w-5 text-gray-400'
        icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>'
        icon.setAttribute('fill', 'none')
        icon.setAttribute('stroke', 'currentColor')
        icon.setAttribute('viewBox', '0 0 24 24')
        
        const fileName = document.createElement('span')
        fileName.className = 'text-sm text-gray-600'
        fileName.textContent = file.name
        
        const fileSize = document.createElement('span')
        fileSize.className = 'text-xs text-gray-500'
        fileSize.textContent = `(${this.formatFileSize(file.size)})`
        
        fileInfo.appendChild(icon)
        fileInfo.appendChild(fileName)
        fileInfo.appendChild(fileSize)
        
        fileItem.appendChild(fileInfo)
        listContainer.appendChild(fileItem)
      })
      
      fileList.appendChild(listContainer)
    }
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}