/*******************************************************************************
 * Copyright (c) 2010-2015, Abel Hegedus, Tamas Borbas, Istvan Rath and Daniel Varro
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Abel Hegedus - initial API and implementation
 *   Tamas Borbas - adapting
 *******************************************************************************/
package org.eclipse.viatra.modelobfuscator.emf.simple

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.viatra.modelobfuscator.api.ModelObfuscator
import org.eclipse.viatra.modelobfuscator.util.StringObfuscator
import com.google.common.base.Preconditions
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource

abstract class AbstractModelObfuscator implements ModelObfuscator {
  protected ResourceSet inputResourceSet
  protected ResourceFilter filter
  protected boolean trace
  protected Map<String,String> obfuscationMap
  protected extension StringObfuscator stringObfuscator

  override obfuscate() {
    modifyModel(true)
  }

  override restore() {
    modifyModel(false)
  }

  protected def modifyModel(boolean obfuscate) {
    Preconditions.checkState(inputResourceSet != null, "Input resourceset must not be null")
    val resources = newArrayList
    resources += inputResourceSet.resources
    // resource list filtered first
    resources.filter[filter == null || !filter.avoidObfuscation(it)].forEach [
      // tree iterator filtered for instances of EObject
      EcoreUtil.getAllContents(it, true).filter(EObject).forEach [ obj |
        // only attributes modified
        obj.eClass.EAllAttributes.filter [
          // we don't need (or can't) to modify such attributes
          changeable && !derived && !volatile &&
          // the value must be String then
          EAttributeType.instanceClass == String
        ].forEach [
          val old = obj.eGet(it)
          if (many) {
            // handle EList values
            val oldValues = old as EList<String>
            val newValues = newArrayList
            oldValues.forEach [
              newValues += it.modifyData(obfuscate)
            ]
            oldValues.clear
            oldValues += newValues
          } else {
            // set single value
            val oldString = old as String
            obj.eSet(it, oldString.modifyData(obfuscate))
          }
        ]
      ]
    ]
  }
  
  protected def String modifyData(String data, boolean obfuscate)

  /**
   * Returns the obfuscator that stores the seed and salt values as well.
   */
  override getStringObfuscator() {
    stringObfuscator
  }
  
  override getObfuscationMap() {
  	obfuscationMap
  }
}

/**
 * Simple interface that can be used to filter out resources, which should
 * not be obfuscated in a resource set.
 * 
 * @author Abel Hegedus
 */
interface ResourceFilter {

  /**
   * Return true if resource should NOT be obfuscated
   */
  def boolean avoidObfuscation(Resource resource)

}