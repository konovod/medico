module Biology

ALL_SYMPTHOMS = {

  Sympthom.new(:Brains, :Insomnia, 0.1, 0.05),
  Sympthom.new(:Brains, :Anxiety, 0.2, 0.02),
  Sympthom.new(:Brains, :Delusion, 0.05, 0.1),
  Sympthom.new(:Brains, :HeadHurt, 0.1, 0.1),
  Sympthom.new(:Brains, :HeadAche, 0.1, 0.1),
  Sympthom.new(:Brains, :Amnesia, 0.2, 0.0),
  Sympthom.new(:Brains, :Vertigo, 0.05, 0.1),
  Sympthom.new(:Brains, :Apraxia, 0.2, 0),
  Sympthom.new(:Brains, :Chorea, 0.2, 0.1),
  Sympthom.new(:Brains, :Depression, 0.1, 0.1),
  Sympthom.new(:Brains, :Hallucination, 0.05, 0.1),

  Sympthom.new(:Circulatory, :Arrhythmia, 0.2, 0),
  Sympthom.new(:Circulatory, :Faints, 0.1, 0.05),
  Sympthom.new(:Circulatory, :ChestPain, 0.1, 0.25),
  Sympthom.new(:Circulatory, :Claudication, 0.15, 0.05),
  Sympthom.new(:Circulatory, :Asthenia, 0.1, 0.1),
  Sympthom.new(:Circulatory, :Epistaxis, 0.05, 0.08),

  Sympthom.new(:Digestion, :Vomit, 0.05, 0.1),
  Sympthom.new(:Digestion, :LossOfAppetite, 0.15, 0.05),
  Sympthom.new(:Digestion, :BodyAche, 0.05, 0.15),
  Sympthom.new(:Digestion, :BodyHurt, 0.05, 0.2),
  Sympthom.new(:Digestion, :FoodPoison, 0, 0.15),
  Sympthom.new(:Digestion, :Xerostomia, 0, 0.1),

  Sympthom.new(:Joints, :JointAche, 0.1, 0.1),
  Sympthom.new(:Joints, :JointHurt, 0.1, 0.15),
  Sympthom.new(:Joints, :BigJoint, 0.05, 0.2),

  Sympthom.new(:LOR, :Cheah, 0, 0.1),
  Sympthom.new(:LOR, :BolVGorle, 0, 0.1),
  Sympthom.new(:LOR, :Nasmork, 0, 0.1),


  Sympthom.new(:Lungs, :Couch, 0.05, 0.1),
  Sympthom.new(:Lungs, :Hrip, 0, 0.15),
  Sympthom.new(:Lungs, :Dyspnea, 0.1, 0.1),
  Sympthom.new(:Lungs, :Hemoptysis, 0.2, 0.1),
  Sympthom.new(:Lungs, :LungsPain, 0.1, 0.05),

}



end
