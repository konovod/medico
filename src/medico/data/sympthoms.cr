module Biology

ALL_SYMPTHOMS = {

  Sympthom.new(System::Brains, :Anxiety, 0.2, 0.02),
  Sympthom.new(System::Brains, :Insomnia, 0.1, 0.05),
  Sympthom.new(System::Brains, :Delusion, 0.05, 0.1),
  Sympthom.new(System::Brains, :HeadHurt, 0.1, 0.1),
  Sympthom.new(System::Brains, :HeadAche, 0.1, 0.1),
  Sympthom.new(System::Brains, :Amnesia, 0.2, 0.0),
  Sympthom.new(System::Brains, :Vertigo, 0.05, 0.1),
  Sympthom.new(System::Brains, :Apraxia, 0.2, 0),
  Sympthom.new(System::Brains, :Chorea, 0.2, 0.1),
  Sympthom.new(System::Brains, :Depression, 0.1, 0.1),
  Sympthom.new(System::Brains, :Hallucination, 0.05, 0.1),

  Sympthom.new(System::Circulatory, :Arrhythmia, 0.2, 0),
  Sympthom.new(System::Circulatory, :Faints, 0.1, 0.05),
  Sympthom.new(System::Circulatory, :ChestPain, 0.1, 0.25),
  Sympthom.new(System::Circulatory, :Claudication, 0.15, 0.05),
  Sympthom.new(System::Circulatory, :Asthenia, 0.1, 0.1),
  Sympthom.new(System::Circulatory, :Epistaxis, 0.05, 0.08),

  Sympthom.new(System::Digestion, :Vomit, 0.05, 0.1),
  Sympthom.new(System::Digestion, :LossOfAppetite, 0.15, 0.05),
  Sympthom.new(System::Digestion, :BodyAche, 0.05, 0.15),
  Sympthom.new(System::Digestion, :BodyHurt, 0.05, 0.2),
  Sympthom.new(System::Digestion, :FoodPoison, 0, 0.15),
  Sympthom.new(System::Digestion, :Xerostomia, 0, 0.1),

  Sympthom.new(System::Joints, :JointAche, 0.1, 0.1),
  Sympthom.new(System::Joints, :JointHurt, 0.1, 0.15),
  Sympthom.new(System::Joints, :BigJoint, 0.05, 0.2),

  Sympthom.new(System::LOR, :Cheah, 0, 0.1),
  Sympthom.new(System::LOR, :BolVGorle, 0, 0.1),
  Sympthom.new(System::LOR, :Nasmork, 0, 0.1),


  Sympthom.new(System::Lungs, :Couch, 0.05, 0.1),
  Sympthom.new(System::Lungs, :Hrip, 0, 0.15),
  Sympthom.new(System::Lungs, :Dyspnea, 0.1, 0.1),
  Sympthom.new(System::Lungs, :Hemoptysis, 0.2, 0.1),
  Sympthom.new(System::Lungs, :LungsPain, 0.1, 0.05),

}



end
