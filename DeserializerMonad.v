(* This is the monad used to write deserializers. It is a state monad with
    failure, where the state is the serialized bits. *)
Definition deserializer (A : Type) : Type := list bool -> option (A * list bool).

Definition ret {A} (a : A) : deserializer A := fun s => Some (a, s).

Definition bind {A B} (m : deserializer A) (f : A -> deserializer B) : deserializer B :=
  fun s => match m s with None => None
                  | Some (a, s') => f a s'
        end.

Definition get : deserializer (list bool) := fun s => Some (s, s).

Definition put (s : list bool) : deserializer unit := fun _ => Some (tt, s).

Definition fail {A} : deserializer A := fun _ => None.


Definition fmap {A B} (f : A -> B) (x : deserializer A) : deserializer B :=
  bind x (fun a => ret (f a)).

Definition sequence {A B} (df : deserializer (A -> B)) (da : deserializer A) : deserializer B :=
  bind df (fun f => (bind da (fun a => ret (f a)))).

Module DeserializerNotations.
  Notation "m >>= f" := (@bind _ _ m f) (at level 42, left associativity).

  Notation "x <- c1 ;; c2" := (c1 >>= (fun x => c2))
                                (at level 100, c1 at next level, right associativity).
  Notation "e1 ;; e2" := (_ <- e1 ;; e2)
                            (at level 100, right associativity).

  Notation "f <$> x" := (@fmap _ _ f x) (at level 42, left associativity).

  Notation "f <*> x" := (@sequence _ _ f x) (at level 42, left associativity).
End DeserializerNotations.