//
//  GraphQLModels.swift
//  Yippi
//
//  Created by Francis Yeap on 5/20/19.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

typealias GrphSticker = MyStickersQuery.Data.User.Sticker

typealias GrphBytedEffect = BytedEffectByCategoryQuery.Data.BytedEffectByCategory.Edge.Node
typealias GrphBytedEffectBundle = BytedEffectByCategoryQuery.Data.BytedEffectByCategory.Edge.Node.Bundle

typealias GrphBytedEffectCategory = BytedEffectCategoriesQuery.Data.BytedEffectCategory.Edge.Node

typealias GrphMusic = BytedEffectSoundQuery.Data.BytedEffectSound.Edge.Node
